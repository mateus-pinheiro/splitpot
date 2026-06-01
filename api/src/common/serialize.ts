import { Prisma } from '@prisma/client';

export const decimalToString = (
  value: Prisma.Decimal | string | number,
): string =>
  value instanceof Prisma.Decimal
    ? value.toFixed(2)
    : new Prisma.Decimal(value).toFixed(2);
