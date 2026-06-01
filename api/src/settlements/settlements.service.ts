import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { SettlementStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import { UsersService } from '../users/users.service.js';
import type { UpdateSettlementPixDto } from './dto/update-settlement-pix.dto.js';

const settlementInclude = {
  fromUser: { select: { id: true, name: true, pixKey: true } },
  toUser: { select: { id: true, name: true, pixKey: true } },
  table: { select: { id: true, name: true, status: true } },
} as const;

@Injectable()
export class SettlementsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly users: UsersService,
  ) {}

  async list(firebaseUid: string, tableId?: string) {
    const user = await this.users.requireByFirebaseUid(firebaseUid);
    return this.prisma.settlement.findMany({
      where: tableId
        ? {
            tableId,
            OR: [
              { fromUserId: user.id },
              { toUserId: user.id },
              { table: { ownerId: user.id } },
            ],
          }
        : { OR: [{ fromUserId: user.id }, { toUserId: user.id }] },
      include: settlementInclude,
      orderBy: { createdAt: 'asc' },
    });
  }

  async confirm(firebaseUid: string, settlementId: string) {
    const user = await this.users.requireByFirebaseUid(firebaseUid);
    const settlement = await this.prisma.settlement.findUnique({
      where: { id: settlementId },
    });
    if (!settlement) throw new NotFoundException('Settlement não encontrado');
    if (settlement.fromUserId !== user.id && settlement.toUserId !== user.id) {
      throw new ForbiddenException(
        'Sem permissão para confirmar este settlement',
      );
    }
    if (settlement.status === SettlementStatus.CONFIRMED) {
      throw new BadRequestException('Settlement já confirmado');
    }
    return this.prisma.settlement.update({
      where: { id: settlementId },
      data: { status: SettlementStatus.CONFIRMED, confirmedAt: new Date() },
      include: settlementInclude,
    });
  }

  async setPix(
    firebaseUid: string,
    settlementId: string,
    dto: UpdateSettlementPixDto,
  ) {
    const user = await this.users.requireByFirebaseUid(firebaseUid);
    const settlement = await this.prisma.settlement.findUnique({
      where: { id: settlementId },
    });
    if (!settlement) throw new NotFoundException('Settlement não encontrado');
    if (settlement.toUserId !== user.id) {
      throw new ForbiddenException('Apenas o recebedor pode anexar código Pix');
    }
    return this.prisma.settlement.update({
      where: { id: settlementId },
      data: { pixCopiaECola: dto.pixCopiaECola },
      include: settlementInclude,
    });
  }
}
