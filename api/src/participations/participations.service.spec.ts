import { BadRequestException } from '@nestjs/common';
import { Prisma, TableStatus } from '@prisma/client';
import { ParticipationsService } from './participations.service.js';
import type { PrismaService } from '../prisma/prisma.service.js';
import type { UsersService } from '../users/users.service.js';
import type { TablesService } from '../tables/tables.service.js';

const PARTICIPATION_ID = 'part-1';

/**
 * Monta o serviço com um Prisma falso. `invested` é a soma dos aportes do
 * jogador (`null` = nenhum buy-in lançado); `updated` registra se o `leftAt`
 * chegou a ser gravado.
 */
function makeService(invested: number | null) {
  const updated: string[] = [];
  const prisma = {
    tableParticipation: {
      findUnique: () =>
        Promise.resolve({
          id: PARTICIPATION_ID,
          tableId: 'table-1',
          userId: 'user-host',
          table: {
            id: 'table-1',
            ownerId: 'user-host',
            status: TableStatus.OPEN,
          },
        }),
      update: ({ where }: { where: { id: string } }) => {
        updated.push(where.id);
        return Promise.resolve({ id: where.id, leftAt: new Date() });
      },
      count: () => Promise.resolve(1),
    },
    buyIn: {
      aggregate: () =>
        Promise.resolve({
          _sum: {
            amount: invested === null ? null : new Prisma.Decimal(invested),
          },
        }),
    },
  } as unknown as PrismaService;

  const users = {
    requireByFirebaseUid: () => Promise.resolve({ id: 'user-host' }),
  } as unknown as UsersService;

  const tables = {
    closeBySystem: () => Promise.resolve({}),
  } as unknown as TablesService;

  return {
    service: new ParticipationsService(prisma, users, tables),
    updated,
  };
}

describe('ParticipationsService.leave', () => {
  it('recusa remover jogador que já aportou', async () => {
    // Remoção e cash-out eram caminhos concorrentes pra "sair da mesa": o
    // host removia quem já tinha fichas e o pote ficava com uma diferença
    // sem dono, travando o fechamento.
    const { service, updated } = makeService(50);

    await expect(service.leave('uid', PARTICIPATION_ID)).rejects.toBeInstanceOf(
      BadRequestException,
    );
    expect(updated).toEqual([]);
  });

  it('permite remover jogador sem nenhum aporte', async () => {
    const { service, updated } = makeService(null);

    await expect(service.leave('uid', PARTICIPATION_ID)).resolves.toBeDefined();
    expect(updated).toEqual([PARTICIPATION_ID]);
  });

  it('permite remover jogador cujos aportes somam zero', async () => {
    const { service, updated } = makeService(0);

    await expect(service.leave('uid', PARTICIPATION_ID)).resolves.toBeDefined();
    expect(updated).toEqual([PARTICIPATION_ID]);
  });
});
