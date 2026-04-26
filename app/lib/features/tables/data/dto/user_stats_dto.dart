import 'package:decimal/decimal.dart';

import '../../domain/entities/table_status.dart';
import '../../domain/entities/user_stats.dart';

class UserStatsDto {
  static UserStats fromJson(Map<String, dynamic> json) {
    final recentsJson = json['recents'] as List<dynamic>? ?? const [];
    return UserStats(
      pnlTotal: _decimal(json['pnlTotal']),
      mesas: json['mesas'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      recents: recentsJson
          .map((e) => _recentFromJson(e as Map<String, dynamic>))
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
