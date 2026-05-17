import 'package:decimal/decimal.dart';

import '../../domain/entities/entities.dart';

class TablePreviewDto {
  static TablePreview fromJson(Map<String, dynamic> json) {
    return TablePreview(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String? ?? '',
      name: json['name'] as String,
      minBuyIn: _decimal(json['minBuyIn']),
      status: _status(json['status'] as String),
      ownerName: json['ownerName'] as String? ?? '',
      participantsCount: json['participantsCount'] as int? ?? 0,
    );
  }

  static Decimal _decimal(Object? value) {
    if (value is String) return Decimal.parse(value);
    if (value is num) return Decimal.parse(value.toString());
    throw StateError('Valor decimal inválido: $value');
  }

  static TableStatus _status(String raw) {
    switch (raw.toUpperCase()) {
      case 'OPEN':
        return TableStatus.open;
      case 'CLOSED':
        return TableStatus.closed;
      default:
        throw StateError('Status de mesa desconhecido: $raw');
    }
  }
}
