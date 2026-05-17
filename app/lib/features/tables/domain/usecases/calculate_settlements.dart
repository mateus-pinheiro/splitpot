import 'package:decimal/decimal.dart';

import '../entities/entities.dart';

/// Calcula o menor conjunto de transferências P2P para acertar a mesa.
///
/// Algoritmo guloso clássico (estilo Splitwise):
///   1. Para cada participação, `net = total(cash_outs) - total(buy_ins)`.
///   2. Separa credores (`net > 0`) e devedores (`net < 0`).
///   3. Enquanto houver par credor/devedor, casa o maior credor com o
///      maior devedor pelo `min(|abs|)`, emite uma transferência e
///      atualiza os saldos residuais. Garante `n - 1` transferências
///      no pior caso.
///
/// Se a soma dos `nets` ≠ 0 (divergência: chips sumiram ou alguém
/// declarou saída incorreta), o algoritmo **não tenta** zerar — ele casa
/// até esgotar um dos lados e o caller é quem sinaliza a divergência
/// na UI via [tableDivergence].
class CalculateSettlements {
  const CalculateSettlements();

  List<SettlementDraft> call({
    required PokerTable table,
    required Map<String, String> userPixByUserId,
  }) {
    final nets = _computeNets(table.participations);

    final creditors = <_Balance>[];
    final debtors = <_Balance>[];
    for (final participation in table.participations) {
      final net = nets[participation.id]!;
      if (net > Decimal.zero) {
        creditors.add(_Balance(participation: participation, remaining: net));
      } else if (net < Decimal.zero) {
        debtors.add(_Balance(participation: participation, remaining: -net));
      }
    }

    creditors.sort((a, b) => b.remaining.compareTo(a.remaining));
    debtors.sort((a, b) => b.remaining.compareTo(a.remaining));

    final settlements = <SettlementDraft>[];
    var creditorIndex = 0;
    var debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];
      final amount = creditor.remaining < debtor.remaining
          ? creditor.remaining
          : debtor.remaining;

      settlements.add(
        SettlementDraft(
          fromUserId: debtor.participation.userId,
          fromUserName: debtor.participation.userName,
          toUserId: creditor.participation.userId,
          toUserName: creditor.participation.userName,
          toPixKey: userPixByUserId[creditor.participation.userId] ?? '',
          amount: amount,
        ),
      );

      creditor.remaining -= amount;
      debtor.remaining -= amount;

      if (creditor.remaining == Decimal.zero) creditorIndex++;
      if (debtor.remaining == Decimal.zero) debtorIndex++;
    }

    return settlements;
  }
}

/// Soma dos buy-ins − soma dos cash-outs agregada pela mesa.
///
/// Positivo: sobrou dinheiro (cash-outs maiores que buy-ins — alguém
/// declarou saída maior do que de fato retirou).
/// Negativo: sumiu dinheiro (buy-ins maiores que cash-outs — chips
/// perdidos, lanche, etc.).
/// Zero: tudo certo.
Decimal tableDivergence(PokerTable table) {
  var totalBuyIns = Decimal.zero;
  var totalCashOuts = Decimal.zero;
  for (final p in table.participations) {
    for (final b in p.buyIns) {
      totalBuyIns += b.amount;
    }
    final cashOut = p.cashOut;
    if (cashOut != null) {
      totalCashOuts += cashOut.amount;
    }
  }
  return totalCashOuts - totalBuyIns;
}

Map<String, Decimal> _computeNets(List<TableParticipation> participations) {
  final result = <String, Decimal>{};
  for (final p in participations) {
    var total = Decimal.zero;
    for (final b in p.buyIns) {
      total -= b.amount;
    }
    final cashOut = p.cashOut;
    if (cashOut != null) {
      total += cashOut.amount;
    }
    result[p.id] = total;
  }
  return result;
}

class _Balance {
  _Balance({required this.participation, required this.remaining});

  final TableParticipation participation;
  Decimal remaining;
}
