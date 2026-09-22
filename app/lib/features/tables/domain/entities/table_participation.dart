import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'buy_in.dart';
import 'cash_out.dart';

part 'table_participation.freezed.dart';

@freezed
abstract class TableParticipation with _$TableParticipation {
  const TableParticipation._();

  const factory TableParticipation({
    required String id,
    required String tableId,
    String? userId,
    required String userName,
    String? guestName,
    String? guestPixKey,
    required DateTime joinedAt,
    DateTime? leftAt,
    @Default(<BuyIn>[]) List<BuyIn> buyIns,
    CashOut? cashOut,
  }) = _TableParticipation;

  /// `true` quando a participação foi adicionada como convidado (sem conta).
  /// O parser de DTO continua preenchendo `userName` para a UI; este getter
  /// existe para regras de negócio que precisam distinguir.
  bool get isGuest => userId == null;

  /// `true` quando o host removeu a participação da mesa.
  bool get wasRemoved => leftAt != null;

  /// Soma dos aportes (buy-in inicial + rebuys).
  Decimal get invested =>
      buyIns.fold(Decimal.zero, (acc, b) => acc + b.amount);

  /// Cash-out efetivo. Removido sem cash-out registrado vale zero — ele saiu
  /// deixando as fichas na mesa.
  Decimal get cashOutAmount => cashOut?.amount ?? Decimal.zero;

  /// `true` se a participação entra na contabilidade da mesa. Espelha
  /// `countsForBalance` da API (`api/src/tables/tables.service.ts`): um
  /// jogador removido continua contando se já movimentou dinheiro, porque os
  /// buy-ins dele são fichas reais no pote. Filtrar só por `leftAt == null`
  /// fazia a tela de conferência esconder justamente quem causava a
  /// diferença que travava o fechamento.
  bool get countsForBalance =>
      leftAt == null || buyIns.isNotEmpty || cashOut != null;
}
