import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_out.freezed.dart';

@freezed
abstract class CashOut with _$CashOut {
  const factory CashOut({
    required String id,
    required String participationId,
    required Decimal amount,
    required DateTime createdAt,
  }) = _CashOut;
}
