import 'package:decimal/decimal.dart';

import 'action_type.dart';

enum ActionRequestStatus { pending, approved, rejected }

class ActionRequest {
  const ActionRequest({
    required this.id,
    required this.participationId,
    required this.tableId,
    required this.requestedById,
    required this.requestedByName,
    required this.type,
    required this.status,
    required this.requestedAt,
    this.amount,
  });

  final String id;
  final String participationId;
  final String tableId;
  final String requestedById;
  final String requestedByName;
  final ActionType type;
  final ActionRequestStatus status;
  final DateTime requestedAt;
  final Decimal? amount;

  String get typeLabel {
    switch (type) {
      case ActionType.buyin:
        return 'Buy-in';
      case ActionType.rebuy:
        return 'Rebuy';
      case ActionType.leave:
        return 'Sair da mesa';
      case ActionType.rejoin:
        return 'Voltar à mesa';
    }
  }

  @override
  bool operator ==(Object other) => other is ActionRequest && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
