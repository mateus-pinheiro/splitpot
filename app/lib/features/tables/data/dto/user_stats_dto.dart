import 'package:decimal/decimal.dart';

import '../../domain/entities/table_status.dart';
import '../../domain/entities/user_stats.dart';

class UserStatsDto {
  static UserStats fromJson(Map<String, dynamic> json) {
    final recentsJson = json['recents'] as List<dynamic>? ?? const [];
    final historyJson = json['history'] as List<dynamic>? ?? const [];
    final debtsJson = json['debts'] as List<dynamic>? ?? const [];
    final receivablesJson = json['receivables'] as List<dynamic>? ?? const [];
    return UserStats(
      pnlTotal: _decimal(json['pnlTotal']),
      mesas: json['mesas'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      recents: recentsJson
          .map((e) => _recentFromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      history: historyJson
          .map((e) => _recentFromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      debts: debtsJson
          .map((e) => _debtFromJson(e as Map<String, dynamic>))
          .toList(growable: false),
        receivables: receivablesJson
          .map((e) => _receivableFromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static RecentTableSummary _recentFromJson(Map<String, dynamic> json) {
    return RecentTableSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      status: _status(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      isHost: json['isHost'] as bool? ?? false,
      players: json['players'] as int? ?? 0,
      pl: json['pl'] == null ? null : _decimal(json['pl']),
      hasPendingSettlements:
          json['hasPendingSettlements'] as bool? ?? false,
    );
  }

  static DebtItem _debtFromJson(Map<String, dynamic> json) {
    return DebtItem(
      id: json['id'] as String,
      amount: _decimal(json['amount']),
      toUserId: json['toUserId'] as String,
      toName: json['toName'] as String,
      toPixKey: json['toPixKey'] as String,
      tableId: json['tableId'] as String,
      tableName: json['tableName'] as String,
      pixCopiaECola: json['pixCopiaECola'] as String?,
    );
  }

  static ReceivableItem _receivableFromJson(Map<String, dynamic> json) {
    return ReceivableItem(
      id: json['id'] as String,
      amount: _decimal(json['amount']),
      fromUserId: json['fromUserId'] as String,
      fromName: json['fromName'] as String,
      tableId: json['tableId'] as String,
      tableName: json['tableName'] as String,
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
