import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  ActionRequestStatus,
  ActionType,
  Prisma,
  TableStatus,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import { UsersService } from '../users/users.service.js';
import { ParticipationsService } from '../participations/participations.service.js';
import type { CreateActionRequestDto } from './dto/create-action-request.dto.js';

@Injectable()
export class ActionRequestsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly users: UsersService,
    private readonly participations: ParticipationsService,
  ) {}

  async create(firebaseUid: string, dto: CreateActionRequestDto) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);

    const participation = await this.prisma.tableParticipation.findUnique({
      where: { id: dto.participationId },
      include: { table: true },
    });
    if (!participation)
      throw new NotFoundException('Participação não encontrada');
    if (participation.table.status !== TableStatus.OPEN) {
      throw new BadRequestException('Mesa fechada não aceita solicitações');
    }
    if (participation.userId !== caller.id) {
      throw new ForbiddenException('Você não é o participante dessa entrada');
    }
    if (participation.table.ownerId === caller.id) {
      throw new BadRequestException(
        'O host executa ações diretamente, sem precisar de aprovação',
      );
    }

    const needsAmount = dto.type !== ActionType.LEAVE;
    if (needsAmount && dto.amount === undefined) {
      throw new BadRequestException(
        'O campo amount é obrigatório para este tipo de ação',
      );
    }

    const existing = await this.prisma.actionRequest.findFirst({
      where: {
        participationId: dto.participationId,
        type: dto.type,
        status: ActionRequestStatus.PENDING,
      },
    });
    if (existing) {
      throw new ConflictException(
        'Já existe uma solicitação pendente deste tipo',
      );
    }

    return this.prisma.actionRequest.create({
      data: {
        tableId: participation.tableId,
        participationId: dto.participationId,
        requestedById: caller.id,
        type: dto.type,
        amount:
          dto.amount !== undefined ? new Prisma.Decimal(dto.amount) : undefined,
      },
      include: { requestedBy: { select: { id: true, name: true } } },
    });
  }

  async approve(firebaseUid: string, requestId: string) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);

    const request = await this.prisma.actionRequest.findUnique({
      where: { id: requestId },
      include: { table: true },
    });
    if (!request) throw new NotFoundException('Solicitação não encontrada');
    if (request.table.ownerId !== caller.id) {
      throw new ForbiddenException('Apenas o host pode aprovar solicitações');
    }
    if (request.status !== ActionRequestStatus.PENDING) {
      throw new BadRequestException('Solicitação já foi resolvida');
    }

    const amount = request.amount ? new Prisma.Decimal(request.amount) : null;

    switch (request.type) {
      case ActionType.BUYIN:
      case ActionType.REBUY:
        await this.participations.executeBuyIn(
          request.participationId,
          amount!,
        );
        break;
      case ActionType.LEAVE:
        await this.participations.executeCashOut(
          request.participationId,
          amount!,
        );
        break;
      case ActionType.REJOIN:
        await this.participations.executeRejoin(
          request.participationId,
          amount!,
        );
        break;
    }

    return this.prisma.actionRequest.update({
      where: { id: requestId },
      data: { status: ActionRequestStatus.APPROVED, resolvedAt: new Date() },
    });
  }

  async reject(firebaseUid: string, requestId: string) {
    const caller = await this.users.requireByFirebaseUid(firebaseUid);

    const request = await this.prisma.actionRequest.findUnique({
      where: { id: requestId },
      include: { table: true },
    });
    if (!request) throw new NotFoundException('Solicitação não encontrada');
    if (request.table.ownerId !== caller.id) {
      throw new ForbiddenException('Apenas o host pode rejeitar solicitações');
    }
    if (request.status !== ActionRequestStatus.PENDING) {
      throw new BadRequestException('Solicitação já foi resolvida');
    }

    return this.prisma.actionRequest.update({
      where: { id: requestId },
      data: { status: ActionRequestStatus.REJECTED, resolvedAt: new Date() },
    });
  }
}
