import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import type { User } from '@prisma/client';
import { Prisma, TableStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import type { ProvisionUserDto } from './dto/provision-user.dto.js';
import type { UpdateUserDto } from './dto/update-user.dto.js';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async provision(
    firebaseUid: string,
    tokenEmail: string | undefined,
    dto: ProvisionUserDto,
  ): Promise<User> {
    const email = dto.email ?? tokenEmail;
    if (!email) {
      throw new ConflictException('Email ausente no token e no payload');
    }

    try {
      return await this.prisma.user.upsert({
        where: { firebaseUid },
        create: { firebaseUid, email, name: dto.name, pixKey: dto.pixKey },
        update: { email, name: dto.name, pixKey: dto.pixKey },
      });
    } catch (err) {
      if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002') {
        throw new ConflictException('Email já utilizado por outro usuário');
      }
      throw err;
    }
  }

  async requireByFirebaseUid(firebaseUid: string): Promise<User> {
    const user = await this.prisma.user.findUnique({ where: { firebaseUid } });
    if (!user) {
      throw new NotFoundException('Usuário ainda não provisionado: chame POST /users/me');
    }
    return user;
  }

  async update(firebaseUid: string, dto: UpdateUserDto): Promise<User> {
    const current = await this.requireByFirebaseUid(firebaseUid);
    return this.prisma.user.update({
      where: { id: current.id },
      data: { name: dto.name ?? current.name, pixKey: dto.pixKey ?? current.pixKey },
    });
  }

  /**
   * Stats agregadas para a home: P&L total / total de mesas fechadas em
   * que o usuário participou / vitórias / lista das 5 mais recentes
   * (com P&L já calculado quando aplicável).
   */
  async getStats(firebaseUid: string) {
    const user = await this.requireByFirebaseUid(firebaseUid);

    const tables = await this.prisma.table.findMany({
      where: {
        OR: [
          { ownerId: user.id },
          { participations: { some: { userId: user.id } } },
        ],
      },
      include: {
        participations: {
          where: { userId: user.id },
          include: { buyIns: true, cashOut: true },
        },
        _count: { select: { participations: true } },
      },
      orderBy: { createdAt: 'desc' },
    });

    let pnlTotal = new Prisma.Decimal(0);
    let mesas = 0;
    let wins = 0;

    for (const t of tables) {
      if (t.status !== TableStatus.CLOSED) continue;
      const mine = t.participations[0];
      if (!mine) continue;
      mesas += 1;
      const pl = this.computePl(mine.buyIns, mine.cashOut);
      pnlTotal = pnlTotal.plus(pl);
      if (pl.greaterThan(0)) wins += 1;
    }

    const recents = tables.slice(0, 5).map((t) => {
      const mine = t.participations[0];
      const pl =
        mine && t.status === TableStatus.CLOSED
          ? this.computePl(mine.buyIns, mine.cashOut).toFixed(2)
          : null;
      return {
        id: t.id,
        name: t.name,
        status: t.status,
        createdAt: t.createdAt,
        closedAt: t.closedAt,
        isHost: t.ownerId === user.id,
        players: t._count.participations,
        pl,
      };
    });

    return {
      pnlTotal: pnlTotal.toFixed(2),
      mesas,
      wins,
      recents,
    };
  }

  private computePl(
    buyIns: { amount: Prisma.Decimal }[],
    cashOut: { amount: Prisma.Decimal } | null,
  ): Prisma.Decimal {
    const sum = buyIns.reduce(
      (acc, b) => acc.plus(b.amount),
      new Prisma.Decimal(0),
    );
    const out = cashOut?.amount ?? new Prisma.Decimal(0);
    return out.minus(sum);
  }
}
