import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settlement_draft.freezed.dart';

/// Transferência P2P calculada pelo fechamento da mesa.
///
/// "Draft" porque ainda não foi efetivada: o pagador precisa fazer o PIX
/// e o recebedor confirmar no app.
@freezed
abstract class SettlementDraft with _$SettlementDraft {
  const factory SettlementDraft({
    String? fromUserId,
    required String fromUserName,
    String? toUserId,
    required String toUserName,
    required String toPixKey,
    required Decimal amount,
  }) = _SettlementDraft;
}
