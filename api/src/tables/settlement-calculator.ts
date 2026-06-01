import { Prisma } from '@prisma/client';

export interface ParticipantNet {
  participationId: string;
  net: Prisma.Decimal;
}

export interface SettlementPlan {
  fromParticipationId: string;
  toParticipationId: string;
  amount: Prisma.Decimal;
}

const ZERO = new Prisma.Decimal(0);
const ROUND_EPSILON = new Prisma.Decimal('0.01');

export function computeSettlements(nets: ParticipantNet[]): SettlementPlan[] {
  const debtors = nets
    .filter((n) => n.net.lessThan(ZERO))
    .map((n) => ({
      participationId: n.participationId,
      remaining: n.net.negated(),
    }))
    .sort((a, b) => b.remaining.comparedTo(a.remaining));

  const creditors = nets
    .filter((n) => n.net.greaterThan(ZERO))
    .map((n) => ({ participationId: n.participationId, remaining: n.net }))
    .sort((a, b) => b.remaining.comparedTo(a.remaining));

  const plans: SettlementPlan[] = [];
  let i = 0;
  let j = 0;

  while (i < debtors.length && j < creditors.length) {
    const debtor = debtors[i];
    const creditor = creditors[j];
    const amount = Prisma.Decimal.min(debtor.remaining, creditor.remaining);

    if (amount.greaterThan(ZERO)) {
      plans.push({
        fromParticipationId: debtor.participationId,
        toParticipationId: creditor.participationId,
        amount,
      });
    }

    debtor.remaining = debtor.remaining.minus(amount);
    creditor.remaining = creditor.remaining.minus(amount);

    if (debtor.remaining.lessThanOrEqualTo(ROUND_EPSILON)) i += 1;
    if (creditor.remaining.lessThanOrEqualTo(ROUND_EPSILON)) j += 1;
  }

  return plans;
}
