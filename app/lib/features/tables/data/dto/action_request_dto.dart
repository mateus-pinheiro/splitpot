import 'package:decimal/decimal.dart';

import '../../domain/entities/entities.dart';

class ActionRequestDto {
  static ActionRequest fromJson(Map<String, dynamic> json) {
    final requester = json['requestedBy'] as Map<String, dynamic>?;
    return ActionRequest(
      id: json['id'] as String,
      participationId: json['participationId'] as String,
      tableId: json['tableId'] as String,
      requestedById: json['requestedById'] as String,
      requestedByName: requester?['name'] as String? ?? '',
      type: _type(json['type'] as String),
      status: _status(json['status'] as String),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      amount: json['amount'] == null ? null : _decimal(json['amount']),
    );
  }

  static ActionType _type(String raw) {
    switch (raw.toUpperCase()) {
      case 'BUYIN':
        return ActionType.buyin;
      case 'REBUY':
        return ActionType.rebuy;
      case 'LEAVE':
        return ActionType.leave;
      case 'REJOIN':
        return ActionType.rejoin;
      default:
        throw StateError('ActionType desconhecido: $raw');
    }
  }

  static ActionRequestStatus _status(String raw) {
    switch (raw.toUpperCase()) {
      case 'PENDING':
        return ActionRequestStatus.pending;
      case 'APPROVED':
        return ActionRequestStatus.approved;
      case 'REJECTED':
        return ActionRequestStatus.rejected;
      default:
        throw StateError('ActionRequestStatus desconhecido: $raw');
    }
  }

  static Decimal _decimal(Object? value) {
    if (value is String) return Decimal.parse(value);
    if (value is num) return Decimal.parse(value.toString());
    throw StateError('Valor decimal inválido: $value');
  }
}
