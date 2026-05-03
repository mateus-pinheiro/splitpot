import 'package:decimal/decimal.dart';

import '../../domain/entities/action_request.dart';
import '../../domain/entities/buy_in.dart';
import '../../domain/entities/cash_out.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/entities/table_participation.dart';
import '../../domain/entities/table_status.dart';
import 'action_request_dto.dart';

/// Mapeia o JSON retornado pela API (Nest + Prisma) pras entidades de
/// domínio. A API serializa `Decimal` como string ("100.00") e enums
/// em UPPERCASE ("OPEN"/"CLOSED").
class TableDto {
  static PokerTable fromJson(Map<String, dynamic> json) {
    final participationsJson = json['participations'] as List<dynamic>? ?? const [];
    final actionRequestsJson = json['actionRequests'] as List<dynamic>? ?? const [];
    return PokerTable(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      minBuyIn: _decimal(json['minBuyIn']),
      status: _status(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      participations: participationsJson
          .map((p) => _participation(p as Map<String, dynamic>))
          .toList(growable: false),
      pendingRequests: actionRequestsJson
          .map((r) => ActionRequestDto.fromJson(r as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static TableParticipation _participation(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final buyInsJson = json['buyIns'] as List<dynamic>? ?? const [];
    final cashOutJson = json['cashOut'] as Map<String, dynamic>?;
    return TableParticipation(
      id: json['id'] as String,
      tableId: json['tableId'] as String,
      userId: json['userId'] as String,
      userName: user?['name'] as String? ?? '',
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      leftAt: json['leftAt'] == null
          ? null
          : DateTime.parse(json['leftAt'] as String),
      buyIns: buyInsJson
          .map((b) => _buyIn(b as Map<String, dynamic>))
          .toList(growable: false),
      cashOut: cashOutJson == null ? null : _cashOut(cashOutJson),
    );
  }

  static BuyIn _buyIn(Map<String, dynamic> json) {
    return BuyIn(
      id: json['id'] as String,
      participationId: json['participationId'] as String,
      amount: _decimal(json['amount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static CashOut _cashOut(Map<String, dynamic> json) {
    return CashOut(
      id: json['id'] as String,
      participationId: json['participationId'] as String,
      amount: _decimal(json['amount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
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

  static Decimal _decimal(Object? value) {
    if (value is String) return Decimal.parse(value);
    if (value is num) return Decimal.parse(value.toString());
    throw StateError('Valor decimal inválido: $value');
  }
}
