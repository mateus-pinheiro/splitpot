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
}
