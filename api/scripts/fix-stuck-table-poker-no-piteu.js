// One-off remediation for table "Poker no Pitéu" (cmp1s45ls000dla04twh8i2p9).
//
// Context: all 8 participants have cash-outs but the sums don't match
// (buy-ins R$750.00 vs cash-outs R$759.50), so the auto-close throws and the
// table is stuck OPEN. The host (Mateus França) agreed to absorb the R$9.50
// discrepancy by reducing his own cash-out, and the real-life PIX transfers
// have already happened — so the resulting settlements are inserted as
// CONFIRMED.
//
// Run locally first, then against prod by swapping DATABASE_URL:
//   node scripts/fix-stuck-table-poker-no-piteu.js
//   node scripts/fix-stuck-table-poker-no-piteu.js --apply   # required to actually write

const { PrismaClient, Prisma } = require('@prisma/client');

const TABLE_ID = 'cmp1s45ls000dla04twh8i2p9';
const HOST_PARTICIPATION_ID = 'cmp1s45ly000fla040v1t3osp'; // Mateus França
const ADJUSTMENT = new Prisma.Decimal('9.50');
// Backdate to when the game actually ended: 00:30 BRT on 2026-05-12 (UTC-3, no DST).
const CLOSED_AT = new Date('2026-05-12T03:30:00.000Z');

const ZERO = new Prisma.Decimal(0);
const ROUND_EPSILON = new Prisma.Decimal('0.01');

function computeSettlements(nets) {
  const debtors = nets
    .filter((n) => n.net.lessThan(ZERO))
    .map((n) => ({ userId: n.userId, remaining: n.net.negated() }))
    .sort((a, b) => b.remaining.comparedTo(a.remaining));

  const creditors = nets
    .filter((n) => n.net.greaterThan(ZERO))
    .map((n) => ({ userId: n.userId, remaining: n.net }))
    .sort((a, b) => b.remaining.comparedTo(a.remaining));

  const plans = [];
  let i = 0;
  let j = 0;
  while (i < debtors.length && j < creditors.length) {
    const debtor = debtors[i];
    const creditor = creditors[j];
    const amount = Prisma.Decimal.min(debtor.remaining, creditor.remaining);
    if (amount.greaterThan(ZERO)) {
      plans.push({
        fromUserId: debtor.userId,
        toUserId: creditor.userId,
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

async function main() {
  const apply = process.argv.includes('--apply');
  const prisma = new PrismaClient();
  try {
    const result = await prisma.$transaction(async (tx) => {
      const table = await tx.table.findUnique({
        where: { id: TABLE_ID },
        include: {
          participations: {
            where: { leftAt: null },
            include: { buyIns: true, cashOut: true, user: true },
            orderBy: { joinedAt: 'asc' },
          },
        },
      });

      if (!table) throw new Error(`Table ${TABLE_ID} not found`);
      if (table.status !== 'OPEN') throw new Error(`Table is ${table.status}, not OPEN`);

      const host = table.participations.find((p) => p.id === HOST_PARTICIPATION_ID);
      if (!host) throw new Error(`Host participation ${HOST_PARTICIPATION_ID} not found in active participants`);
      if (!host.cashOut) throw new Error('Host has no cash-out to adjust');

      const oldHostCashOut = host.cashOut.amount;
      const newHostCashOut = oldHostCashOut.minus(ADJUSTMENT);

      console.log(`Adjusting cash-out for ${host.user.name}: ${oldHostCashOut.toFixed(2)} → ${newHostCashOut.toFixed(2)}`);

      // Sanity: recompute nets with the adjustment applied in-memory.
      let totalBuyIn = ZERO;
      let totalCashOut = ZERO;
      const nets = table.participations.map((p) => {
        const buyInSum = p.buyIns.reduce((acc, b) => acc.plus(b.amount), ZERO);
        const cashOutAmount = p.id === host.id ? newHostCashOut : p.cashOut.amount;
        totalBuyIn = totalBuyIn.plus(buyInSum);
        totalCashOut = totalCashOut.plus(cashOutAmount);
        return { userId: p.userId, name: p.user.name, net: cashOutAmount.minus(buyInSum) };
      });

      console.log(`\nAfter adjustment: total buy-in ${totalBuyIn.toFixed(2)} vs cash-out ${totalCashOut.toFixed(2)}`);
      if (!totalBuyIn.equals(totalCashOut)) {
        throw new Error(`Totals still don't match after R$${ADJUSTMENT.toFixed(2)} adjustment`);
      }

      console.log('\nPer-player nets:');
      for (const n of nets) {
        const sign = n.net.greaterThanOrEqualTo(ZERO) ? '+' : '';
        console.log(`  ${n.name.padEnd(22)} ${sign}${n.net.toFixed(2)}`);
      }

      const plans = computeSettlements(nets.map(({ userId, net }) => ({ userId, net })));
      const userById = new Map(table.participations.map((p) => [p.userId, p.user.name]));

      console.log(`\nWill create ${plans.length} settlement(s) (status=CONFIRMED):`);
      for (const p of plans) {
        console.log(`  ${userById.get(p.fromUserId)} → ${userById.get(p.toUserId)}: R$${p.amount.toFixed(2)}`);
      }

      if (!apply) {
        // Roll back the transaction by throwing — keeps DB untouched in dry-run.
        throw new DryRunRollback();
      }

      // Apply changes.
      await tx.cashOut.update({
        where: { participationId: host.id },
        data: { amount: newHostCashOut },
      });

      if (plans.length > 0) {
        await tx.settlement.createMany({
          data: plans.map((p) => ({
            tableId: TABLE_ID,
            fromUserId: p.fromUserId,
            toUserId: p.toUserId,
            amount: p.amount,
            status: 'CONFIRMED',
            confirmedAt: CLOSED_AT,
          })),
        });
      }

      await tx.table.update({
        where: { id: TABLE_ID },
        data: { status: 'CLOSED', closedAt: CLOSED_AT },
      });

      return { settlementsCreated: plans.length };
    });

    console.log(`\n✅ APPLIED. Settlements created: ${result.settlementsCreated}. Table CLOSED.`);
  } catch (err) {
    if (err instanceof DryRunRollback) {
      console.log('\nDRY RUN — nothing written. Re-run with --apply to commit.');
      return;
    }
    throw err;
  } finally {
    await prisma.$disconnect();
  }
}

class DryRunRollback extends Error {}

main().catch((e) => {
  console.error('\n❌ FAILED:', e.message);
  process.exit(1);
});
