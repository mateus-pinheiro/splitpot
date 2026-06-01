import 'package:decimal/decimal.dart';

enum SettlementStatus { pending, confirmed }

class Settlement {
  const Settlement({
    required this.id,
    required this.tableId,
    this.fromUserId,
    required this.fromName,
    this.fromPixKey,
    this.toUserId,
    required this.toName,
    required this.toPixKey,
    required this.amount,
    required this.status,
    this.pixCopiaECola,
  });

  final String id;
  final String tableId;

  /// Nulo quando o pagador é convidado (sem conta).
  final String? fromUserId;
  final String fromName;
  final String? fromPixKey;

  /// Nulo quando o recebedor é convidado.
  final String? toUserId;
  final String toName;

  /// PIX do destinatário — vem denormalizado do backend (congela no fechamento).
  final String toPixKey;
  final Decimal amount;
  final SettlementStatus status;
  final String? pixCopiaECola;

  bool get isFromGuest => fromUserId == null;
  bool get isToGuest => toUserId == null;
}
