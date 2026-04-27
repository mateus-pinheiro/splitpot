import 'package:decimal/decimal.dart';

enum SettlementStatus { pending, confirmed }

class Settlement {
  const Settlement({
    required this.id,
    required this.tableId,
    required this.fromUserId,
    required this.fromName,
    this.fromPixKey,
    required this.toUserId,
    required this.toName,
    required this.toPixKey,
    required this.amount,
    required this.status,
    this.pixCopiaECola,
  });

  final String id;
  final String tableId;
  final String fromUserId;
  final String fromName;
  final String? fromPixKey;
  final String toUserId;
  final String toName;
  final String toPixKey;
  final Decimal amount;
  final SettlementStatus status;
  final String? pixCopiaECola;
}
