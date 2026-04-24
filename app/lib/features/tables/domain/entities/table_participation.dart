import 'package:freezed_annotation/freezed_annotation.dart';

import 'buy_in.dart';
import 'cash_out.dart';

part 'table_participation.freezed.dart';

@freezed
abstract class TableParticipation with _$TableParticipation {
  const factory TableParticipation({
    required String id,
    required String tableId,
    required String userId,
    required String userName,
    required DateTime joinedAt,
    DateTime? leftAt,
    @Default(<BuyIn>[]) List<BuyIn> buyIns,
    CashOut? cashOut,
  }) = _TableParticipation;
}
