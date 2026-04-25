import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, TableStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import { UsersService } from '../users/users.service.js';
import type { AddBuyInDto } from './dto/add-buy-in.dto.js';
import type { CreateParticipationDto } from './dto/create-participation.dto.js';
import type { SetCashOutDto } from './dto/set-cash-out.dto.js';

@Injectable()
export class ParticipationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly users: UsersService,
  ) {}

  async join(firebaseUid: string, dto: CreateParticipationDto) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    const table = await this.prisma.table.findUnique({ where: { id: dto.tableId } });
    if (!table) throw new NotFoundException('Mesa não encontrada');
    if (table.status !== TableStatus.OPEN) {
      throw new BadRequestException('Mesa fechada não aceita novos participantes');
    }

    const targetUserId = dto.userId ?? caller.id;
    if (targetUserId !== caller.id && table.ownerId !== caller.id) {
      throw new ForbiddenException('Apenas o dono pode adicionar outros participantes');
    }

    if (targetUserId !== caller.id) {
      const exists = await this.prisma.user.findUnique({ where: { id: targetUserId } });
      if (!exists) throw new NotFoundException('Usuário alvo não encontrado');
    }

    if (dto.initialBuyIn !== undefined) {
      const min = new Prisma.Decimal(table.minBuyIn);
      const requested = new Prisma.Decimal(dto.initialBuyIn);
      if (requested.lessThan(min)) {
        throw new BadRequestException(
          `Buy-in inicial precisa ser ≥ R$ ${min.toFixed(2)}.`,
        );
      }
    }

    try {
      return await this.prisma.$transaction(async (tx) => {
        const participation = await tx.tableParticipation.create({
          data: { tableId: table.id, userId: targetUserId },
        });
        if (dto.initialBuyIn !== undefined) {
          await tx.buyIn.create({
            data: {
              participationId: participation.id,
              amount: new Prisma.Decimal(dto.initialBuyIn),
            },
          });
        }
        return tx.tableParticipation.findUniqueOrThrow({
          where: { id: participation.id },
          include: { buyIns: true },
        });
      });
    } catch (err) {
      if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
        throw new BadRequestException('Usuário já participa dessa mesa');
      }
      throw err;
    }
  }

  async leave(firebaseUid: string, participationId: string) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    const participation = await this.prisma.tableParticipation.findUnique({
      where: { id: participationId },
      include: { table: true },
    });
    if (!participation) throw new NotFoundException('Participação não encontrada');
    if (participation.table.status !== TableStatus.OPEN) {
      throw new BadRequestException('Mesa fechada não aceita alterações');
    }
    const canLeave =
      participation.userId === caller.id || participation.table.ownerId === caller.id;
    if (!canLeave) throw new ForbiddenException('Sem permissão para remover essa participação');

    return this.prisma.tableParticipation.update({
      where: { id: participationId },
      data: { leftAt: new Date() },
    });
  }

  async addBuyIn(firebaseUid: string, participationId: string, dto: AddBuyInDto) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    const participation = await this.requireEditable(participationId, caller.id);
    return this.prisma.buyIn.create({
      data: {
        participationId: participation.id,
        amount: new Prisma.Decimal(dto.amount),
      },
    });
  }

  async removeBuyIn(firebaseUid: string, participationId: string, buyInId: string) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    await this.requireEditable(participationId, caller.id);
    const buyIn = await this.prisma.buyIn.findUnique({ where: { id: buyInId } });
    if (!buyIn || buyIn.participationId !== participationId) {
      throw new NotFoundException('Buy-in não encontrado nessa participação');
    }
    await this.prisma.buyIn.delete({ where: { id: buyInId } });
  }

  async setCashOut(firebaseUid: string, participationId: string, dto: SetCashOutDto) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    const participation = await this.requireEditable(participationId, caller.id);
    return this.prisma.cashOut.upsert({
      where: { participationId: participation.id },
      create: {
        participationId: participation.id,
        amount: new Prisma.Decimal(dto.amount),
      },
      update: { amount: new Prisma.Decimal(dto.amount) },
    });
  }

  private async requireEditable(participationId: string, callerUserId: string) {
    const participation = await this.prisma.tableParticipation.findUnique({
      where: { id: participationId },
      include: { table: true },
    });
    if (!participation) throw new NotFoundException('Participação não encontrada');
    if (participation.table.status !== TableStatus.OPEN) {
      throw new BadRequestException('Mesa fechada não aceita alterações');
    }
    const allowed =
      participation.userId === callerUserId || participation.table.ownerId === callerUserId;
    if (!allowed) throw new ForbiddenException('Sem permissão para alterar essa participação');
    return participation;
  }
}
