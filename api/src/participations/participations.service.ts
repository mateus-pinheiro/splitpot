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
import { TablesService } from '../tables/tables.service.js';

@Injectable()
export class ParticipationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly users: UsersService,
    private readonly tables: TablesService,
  ) {}

  async join(firebaseUid: string, dto: CreateParticipationDto) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    const table = await this.prisma.table.findUnique({
      where: { id: dto.tableId },
    });
    if (!table) throw new NotFoundException('Mesa não encontrada');
    if (table.status !== TableStatus.OPEN) {
      throw new BadRequestException(
        'Mesa fechada não aceita novos participantes',
      );
    }

    const isGuest = dto.guestName !== undefined;
    if (isGuest && dto.userId !== undefined) {
      throw new BadRequestException('Informe userId OU guestName, nunca ambos');
    }
    if (isGuest && !dto.guestPixKey) {
      throw new BadRequestException('Convidado precisa de PIX');
    }
    if (isGuest && table.ownerId !== caller.id) {
      throw new ForbiddenException('Apenas o host pode adicionar convidados');
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

    let createData: Prisma.TableParticipationCreateInput;
    if (isGuest) {
      createData = {
        table: { connect: { id: table.id } },
        guestName: dto.guestName!,
        guestPixKey: dto.guestPixKey!,
      };
    } else {
      const targetUserId = dto.userId ?? caller.id;
      if (targetUserId !== caller.id && table.ownerId !== caller.id) {
        throw new ForbiddenException(
          'Apenas o dono pode adicionar outros participantes',
        );
      }
      if (targetUserId !== caller.id) {
        const exists = await this.prisma.user.findUnique({
          where: { id: targetUserId },
        });
        if (!exists) {
          throw new NotFoundException('Usuário alvo não encontrado');
        }
      }
      createData = {
        table: { connect: { id: table.id } },
        user: { connect: { id: targetUserId } },
      };
    }

    try {
      return await this.prisma.$transaction(async (tx) => {
        const participation = await tx.tableParticipation.create({
          data: createData,
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
      if (
        err instanceof Prisma.PrismaClientKnownRequestError &&
        err.code === 'P2002'
      ) {
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
    if (!participation)
      throw new NotFoundException('Participação não encontrada');
    if (participation.table.status !== TableStatus.OPEN) {
      throw new BadRequestException('Mesa fechada não aceita alterações');
    }
    const canLeave =
      participation.userId === caller.id ||
      participation.table.ownerId === caller.id;
    if (!canLeave)
      throw new ForbiddenException(
        'Sem permissão para remover essa participação',
      );

    const updated = await this.prisma.tableParticipation.update({
      where: { id: participationId },
      data: { leftAt: new Date() },
    });

    const remaining = await this.prisma.tableParticipation.count({
      where: { tableId: participation.tableId, leftAt: null },
    });
    if (remaining === 0) {
      await this.tables.closeBySystem(participation.tableId);
    }

    return updated;
  }

  async addBuyIn(
    firebaseUid: string,
    participationId: string,
    dto: AddBuyInDto,
  ) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    const participation = await this.requireEditable(
      participationId,
      caller.id,
    );
    return this.executeBuyIn(participation.id, new Prisma.Decimal(dto.amount));
  }

  async removeBuyIn(
    firebaseUid: string,
    participationId: string,
    buyInId: string,
  ) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    await this.requireEditable(participationId, caller.id);
    const buyIn = await this.prisma.buyIn.findUnique({
      where: { id: buyInId },
    });
    if (!buyIn || buyIn.participationId !== participationId) {
      throw new NotFoundException('Buy-in não encontrado nessa participação');
    }
    await this.prisma.buyIn.delete({ where: { id: buyInId } });
  }

  async updateBuyIn(
    firebaseUid: string,
    participationId: string,
    buyInId: string,
    dto: AddBuyInDto,
  ) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    await this.requireEditable(participationId, caller.id);
    const buyIn = await this.prisma.buyIn.findUnique({
      where: { id: buyInId },
    });
    if (!buyIn || buyIn.participationId !== participationId) {
      throw new NotFoundException('Buy-in não encontrado nessa participação');
    }
    return this.prisma.buyIn.update({
      where: { id: buyInId },
      data: { amount: new Prisma.Decimal(dto.amount) },
    });
  }

  async setCashOut(
    firebaseUid: string,
    participationId: string,
    dto: SetCashOutDto,
    skipAutoClose = false,
  ) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    const participation = await this.requireEditable(
      participationId,
      caller.id,
    );
    return this.executeCashOut(
      participation.id,
      new Prisma.Decimal(dto.amount),
      skipAutoClose,
    );
  }

  async removeCashOut(firebaseUid: string, participationId: string) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    await this.requireEditable(participationId, caller.id);
    await this.prisma.cashOut.deleteMany({ where: { participationId } });
  }

  async rejoin(firebaseUid: string, participationId: string, dto: AddBuyInDto) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);
    await this.requireEditable(participationId, caller.id);
    return this.executeRejoin(participationId, new Prisma.Decimal(dto.amount));
  }

  // ── Internal execution methods (sem verificação de autenticação) ──────────
  // Chamados pelo ActionRequestsService ao aprovar uma solicitação.

  async executeBuyIn(participationId: string, amount: Prisma.Decimal) {
    return this.prisma.buyIn.create({
      data: { participationId, amount },
    });
  }

  async executeCashOut(
    participationId: string,
    amount: Prisma.Decimal,
    skipAutoClose = false,
  ) {
    const participation = await this.prisma.tableParticipation.findUnique({
      where: { id: participationId },
      select: { tableId: true },
    });
    if (!participation)
      throw new NotFoundException('Participação não encontrada');

    const cashOut = await this.prisma.cashOut.upsert({
      where: { participationId },
      create: { participationId, amount },
      update: { amount },
    });

    const activeParticipations = await this.prisma.tableParticipation.findMany({
      where: { tableId: participation.tableId, leftAt: null },
      select: { id: true },
    });
    const cashOutCount = await this.prisma.cashOut.count({
      where: { participationId: { in: activeParticipations.map((p) => p.id) } },
    });
    if (
      !skipAutoClose &&
      activeParticipations.length > 0 &&
      cashOutCount === activeParticipations.length
    ) {
      // Auto-close best-effort: when buy-ins and cash-outs don't reconcile,
      // closeBySystem throws BadRequestException. The cash-out itself is
      // already committed and the table moves into a "needs reconciliation"
      // state (surfaced via GET /tables/:id) instead of failing the request.
      // `skipAutoClose` é usado pelo fluxo de conferência (host empurra vários
      // ajustes antes de fechar explicitamente) pra evitar fechar no meio.
      try {
        await this.tables.closeBySystem(participation.tableId);
      } catch (err) {
        if (!(err instanceof BadRequestException)) throw err;
      }
    }

    return cashOut;
  }

  async executeRejoin(participationId: string, amount: Prisma.Decimal) {
    return this.prisma.$transaction(async (tx) => {
      await tx.cashOut.deleteMany({ where: { participationId } });
      return tx.buyIn.create({
        data: { participationId, amount },
      });
    });
  }

  private async requireEditable(participationId: string, callerUserId: string) {
    const participation = await this.prisma.tableParticipation.findUnique({
      where: { id: participationId },
      include: { table: true },
    });
    if (!participation)
      throw new NotFoundException('Participação não encontrada');
    if (participation.table.status !== TableStatus.OPEN) {
      throw new BadRequestException('Mesa fechada não aceita alterações');
    }
    const allowed =
      participation.userId === callerUserId ||
      participation.table.ownerId === callerUserId;
    if (!allowed)
      throw new ForbiddenException(
        'Sem permissão para alterar essa participação',
      );
    return participation;
  }
}
