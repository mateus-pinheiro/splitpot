import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, TableStatus, type Table } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import { UsersService } from '../users/users.service.js';
import type { CreateTableDto } from './dto/create-table.dto.js';
import type { UpdateTableDto } from './dto/update-table.dto.js';
import { computeSettlements, type ParticipantNet } from './settlement-calculator.js';

@Injectable()
export class TablesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly users: UsersService,
  ) {}

  async create(firebaseUid: string, dto: CreateTableDto): Promise<Table> {
    const owner = await this.users.requireByFirebaseUid(firebaseUid);
    return this.prisma.$transaction(async (tx) => {
      const table = await tx.table.create({
        data: {
          ownerId: owner.id,
          name: dto.name,
          minBuyIn: new Prisma.Decimal(dto.minBuyIn),
        },
      });
      if (dto.joinAsPlayer === true) {
        await tx.tableParticipation.create({
          data: { tableId: table.id, userId: owner.id },
        });
      }
      return table;
    });
  }

  async listForUser(firebaseUid: string) {
    const user = await this.users.requireByFirebaseUid(firebaseUid);
    return this.prisma.table.findMany({
      where: {
        OR: [{ ownerId: user.id }, { participations: { some: { userId: user.id } } }],
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Visão pública mínima da mesa: serve a tela de pre-join, onde o
   * convidado ainda não é participant e não pode chamar `getById`. Não
   * expõe PIX, buy-ins, cash-outs nem listas — só o suficiente pra
   * decidir entrar.
   */
  async getPreviewById(firebaseUid: string, tableId: string) {
    await this.users.requireByFirebaseUid(firebaseUid);
    const table = await this.prisma.table.findUnique({
      where: { id: tableId },
      select: {
        id: true,
        name: true,
        minBuyIn: true,
        status: true,
        owner: { select: { name: true } },
        _count: { select: { participations: true } },
      },
    });
    if (!table) throw new NotFoundException('Mesa não encontrada');
    return {
      id: table.id,
      name: table.name,
      minBuyIn: table.minBuyIn,
      status: table.status,
      ownerName: table.owner.name,
      participantsCount: table._count.participations,
    };
  }

  async getById(firebaseUid: string, tableId: string) {
    const user = await this.users.requireByFirebaseUid(firebaseUid);
    const table = await this.prisma.table.findUnique({
      where: { id: tableId },
      include: {
        owner: { select: { id: true, name: true, email: true } },
        participations: {
          include: {
            user: { select: { id: true, name: true, email: true, pixKey: true } },
            buyIns: true,
            cashOut: true,
          },
          orderBy: { joinedAt: 'asc' },
        },
        settlements: {
          include: {
            fromUser: { select: { id: true, name: true, pixKey: true } },
            toUser: { select: { id: true, name: true, pixKey: true } },
          },
          orderBy: { createdAt: 'asc' },
        },
      },
    });
    if (!table) throw new NotFoundException('Mesa não encontrada');

    const isOwner = table.ownerId === user.id;
    const isParticipant = table.participations.some((p) => p.userId === user.id);
    if (!isOwner && !isParticipant) {
      throw new ForbiddenException('Sem acesso a essa mesa');
    }
    return table;
  }

  async update(firebaseUid: string, tableId: string, dto: UpdateTableDto): Promise<Table> {
    const user = await this.users.requireByFirebaseUid(firebaseUid);
    const table = await this.prisma.table.findUnique({ where: { id: tableId } });
    if (!table) throw new NotFoundException('Mesa não encontrada');
    if (table.ownerId !== user.id) throw new ForbiddenException('Apenas o dono pode editar');
    if (table.status !== TableStatus.OPEN) {
      throw new BadRequestException('Mesa fechada não pode ser editada');
    }

    return this.prisma.$transaction(async (tx) => {
      const updated = await tx.table.update({
        where: { id: tableId },
        data: {
          name: dto.name ?? table.name,
          minBuyIn: dto.minBuyIn !== undefined ? new Prisma.Decimal(dto.minBuyIn) : table.minBuyIn,
        },
      });

      if (dto.joinAsPlayer === true) {
        // Garante que o owner tem participação ativa
        await tx.tableParticipation.upsert({
          where: { tableId_userId: { tableId, userId: user.id } },
          create: { tableId, userId: user.id },
          update: { leftAt: null },
        });
      } else if (dto.joinAsPlayer === false) {
        // Remove a participação do owner se ele ainda não fez buy-in
        const participation = await tx.tableParticipation.findUnique({
          where: { tableId_userId: { tableId, userId: user.id } },
          include: { _count: { select: { buyIns: true } } },
        });
        if (participation && participation._count.buyIns === 0) {
          await tx.tableParticipation.delete({
            where: { id: participation.id },
          });
        }
      }

      return updated;
    });
  }

  async close(firebaseUid: string, tableId: string) {
    const user = await this.users.requireByFirebaseUid(firebaseUid);
    const table = await this.prisma.table.findUnique({ where: { id: tableId } });
    if (!table) throw new NotFoundException('Mesa não encontrada');
    if (table.ownerId !== user.id) throw new ForbiddenException('Apenas o dono pode fechar');
    return this.closeBySystem(tableId);
  }

  async closeBySystem(tableId: string) {
    return this.prisma.$transaction(async (tx) => {
      const table = await tx.table.findUnique({
        where: { id: tableId },
        include: {
          participations: {
            where: { leftAt: null },
            include: { buyIns: true, cashOut: true },
          },
        },
      });
      if (!table) throw new NotFoundException('Mesa não encontrada');
      if (table.status !== TableStatus.OPEN) {
        throw new BadRequestException('Mesa já está fechada');
      }
      if (table.participations.length === 0) {
        throw new BadRequestException('Mesa sem participantes');
      }

      const missingCashOut = table.participations.filter((p) => !p.cashOut);
      if (missingCashOut.length > 0) {
        throw new BadRequestException(
          `Cash-out pendente para ${missingCashOut.length} participante(s)`,
        );
      }

      let totalBuyIn = new Prisma.Decimal(0);
      let totalCashOut = new Prisma.Decimal(0);
      const nets: ParticipantNet[] = table.participations.map((p) => {
        const buyInSum = p.buyIns.reduce(
          (acc, b) => acc.plus(b.amount),
          new Prisma.Decimal(0),
        );
        const cashOutAmount = p.cashOut!.amount;
        totalBuyIn = totalBuyIn.plus(buyInSum);
        totalCashOut = totalCashOut.plus(cashOutAmount);
        return { userId: p.userId, net: cashOutAmount.minus(buyInSum) };
      });

      if (!totalBuyIn.equals(totalCashOut)) {
        throw new BadRequestException(
          `Soma de buy-ins (${totalBuyIn.toFixed(2)}) diferente da soma de cash-outs (${totalCashOut.toFixed(2)})`,
        );
      }

      const plans = computeSettlements(nets);

      if (plans.length > 0) {
        await tx.settlement.createMany({
          data: plans.map((p) => ({
            tableId: table.id,
            fromUserId: p.fromUserId,
            toUserId: p.toUserId,
            amount: p.amount,
          })),
        });
      }

      return tx.table.update({
        where: { id: table.id },
        data: { status: TableStatus.CLOSED, closedAt: new Date() },
        include: {
          settlements: {
            include: {
              fromUser: { select: { id: true, name: true, pixKey: true } },
              toUser: { select: { id: true, name: true, pixKey: true } },
            },
          },
        },
      });
    });
  }
}
