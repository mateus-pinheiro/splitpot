import { BadRequestException } from '@nestjs/common';
import { Prisma, TableStatus } from '@prisma/client';
import { TablesService } from './tables.service.js';
import type { PrismaService } from '../prisma/prisma.service.js';
import type { UsersService } from '../users/users.service.js';

const dec = (v: string | number) => new Prisma.Decimal(v);

type FakeParticipation = {
  id: string;
  userId: string | null;
  guestName: string | null;
  guestPixKey: string | null;
  leftAt: Date | null;
  buyIns: { amount: Prisma.Decimal }[];
  cashOut: { amount: Prisma.Decimal } | null;
  user: { id: string; pixKey: string } | null;
};

const player = (
  id: string,
  buyIns: number[],
  cashOut: number | null,
  opts: { leftAt?: Date } = {},
): FakeParticipation => ({
  id,
  userId: `user-${id}`,
  guestName: null,
  guestPixKey: null,
  leftAt: opts.leftAt ?? null,
  buyIns: buyIns.map((a) => ({ amount: dec(a) })),
  cashOut: cashOut === null ? null : { amount: dec(cashOut) },
  user: { id: `user-${id}`, pixKey: `${id}@pix` },
});

type CreatedSettlement = {
  fromUserId: string;
  toUserId: string;
  amount: Prisma.Decimal;
};

/**
 * Prisma falso: só o suficiente pro caminho de fechamento. `created` guarda
 * os settlements gerados e `closed` os status aplicados na mesa.
 */
function fakePrisma(participations: FakeParticipation[]) {
  const created: CreatedSettlement[] = [];
  const closed: TableStatus[] = [];
  const tx = {
    table: {
      findUnique: () =>
        Promise.resolve({
          id: 'table-1',
          ownerId: 'user-host',
          status: TableStatus.OPEN,
          participations,
        }),
      update: (args: { data: { status: TableStatus } }) => {
        closed.push(args.data.status);
        return Promise.resolve({ id: 'table-1', status: args.data.status });
      },
    },
    settlement: {
      createMany: ({ data }: { data: CreatedSettlement[] }) => {
        created.push(...data);
        return Promise.resolve({ count: data.length });
      },
    },
  };
  const prisma = {
    $transaction: (cb: (tx: unknown) => unknown) => cb(tx),
  } as unknown as PrismaService;
  return { prisma, created, closed };
}

const makeService = (participations: FakeParticipation[]) => {
  const { prisma, created, closed } = fakePrisma(participations);
  const service = new TablesService(prisma, {} as UsersService);
  return { service, created, closed };
};

const sum = (settlements: CreatedSettlement[]) =>
  settlements.reduce((acc, s) => acc.plus(s.amount), dec(0));

describe('TablesService.closeBySystem', () => {
  it('conta o jogador removido que já movimentou dinheiro', async () => {
    // Regressão da mesa que travou em produção: uma jogadora foi removida
    // pelo host com buy-in de 100 e cash-out de 325. Filtrando por
    // `leftAt: null` sumiam R$ 225 da conta e a mesa ficava OPEN sem nada
    // pra ajustar na tela de conferência — ela nem aparecia lá.
    const { service, created, closed } = makeService([
      player('host', [100], 0),
      player('b', [100], 0),
      player('removida', [100], 325, {
        leftAt: new Date('2026-08-12T22:30:00Z'),
      }),
      player('c', [], 155),
      player('d', [300], 105),
      player('e', [50], 130),
      player('f', [150], 85),
    ]);

    await service.closeBySystem('table-1');

    expect(closed).toEqual([TableStatus.CLOSED]);
    // A removida recebe os 225 de lucro; o total transferido fecha com a
    // soma dos negativos (100 + 100 + 195 + 65).
    expect(sum(created).toFixed(2)).toBe('460.00');
    expect(
      sum(created.filter((s) => s.toUserId === 'user-removida')).toFixed(2),
    ).toBe('225.00');
  });

  it('trata removido sem cash-out como saída zero', async () => {
    const { service, created } = makeService([
      player('host', [50], 100),
      player('removido', [50], null, { leftAt: new Date() }),
    ]);

    await service.closeBySystem('table-1');

    expect(created).toHaveLength(1);
    expect(created[0].fromUserId).toBe('user-removido');
    expect(created[0].toUserId).toBe('user-host');
    expect(created[0].amount.toFixed(2)).toBe('50.00');
  });

  it('ignora participação removida que nunca movimentou dinheiro', async () => {
    const { service, closed } = makeService([
      player('host', [50], 50),
      player('fantasma', [], null, { leftAt: new Date() }),
    ]);

    await expect(service.closeBySystem('table-1')).resolves.toBeDefined();
    expect(closed).toEqual([TableStatus.CLOSED]);
  });

  it('ainda bloqueia quando um participante ativo não declarou cash-out', async () => {
    const { service } = makeService([
      player('host', [50], 50),
      player('ativo', [50], null),
    ]);

    await expect(service.closeBySystem('table-1')).rejects.toBeInstanceOf(
      BadRequestException,
    );
  });

  it('ainda bloqueia quando as somas não batem', async () => {
    const { service } = makeService([
      player('host', [50], 60),
      player('outro', [50], 50),
    ]);

    await expect(service.closeBySystem('table-1')).rejects.toThrow(
      /Soma de buy-ins/,
    );
  });
});
