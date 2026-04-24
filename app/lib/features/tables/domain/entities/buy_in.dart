import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'buy_in.freezed.dart';

@freezed
abstract class BuyIn with _$BuyIn {
  const factory BuyIn({
    required String id,
    required String participationId,
    required Decimal amount,
    required DateTime createdAt,
  }) = _BuyIn;
}
