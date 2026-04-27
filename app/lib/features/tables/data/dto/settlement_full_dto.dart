import 'package:decimal/decimal.dart';

import '../../domain/entities/settlement.dart';

class SettlementFullDto {
  static Settlement fromJson(Map<String, dynamic> json) {
    final from = json['fromUser'] as Map<String, dynamic>?;
    final to = json['toUser'] as Map<String, dynamic>?;
    return Settlement(
      id: json['id'] as String,
      tableId: json['tableId'] as String,
      fromUserId: json['fromUserId'] as String,
      fromName: from?['name'] as String? ?? '',
      fromPixKey: from?['pixKey'] as String?,
      toUserId: json['toUserId'] as String,
      toName: to?['name'] as String? ?? '',
      toPixKey: to?['pixKey'] as String? ?? '',
      amount: _decimal(json['amount']),
      status: _status(json['status'] as String),
      pixCopiaECola: json['pixCopiaECola'] as String?,
    );
  }

  static Decimal _decimal(Object? value) {
    if (value is String) return Decimal.parse(value);
    if (value is num) return Decimal.parse(value.toString());
    throw StateError('Valor decimal inválido: $value');
  }

  static SettlementStatus _status(String raw) {
    switch (raw.toUpperCase()) {
      case 'PENDING':
        return SettlementStatus.pending;
      case 'CONFIRMED':
        return SettlementStatus.confirmed;
      default:
        throw StateError('Status de settlement desconhecido: $raw');
    }
  }
}
