import 'package:decimal/decimal.dart';

import 'table_status.dart';

/// Estatísticas agregadas do usuário usadas na home.
/// `recents` traz até 5 mesas (qualquer status), com `pl` apenas quando
/// fechada e o user participou.
class UserStats {
  const UserStats({
    required this.pnlTotal,
    required this.mesas,
    required this.wins,
    required this.recents,
  });

  final Decimal pnlTotal;
  final int mesas;
  final int wins;
  final List<RecentTableSummary> recents;
}

class RecentTableSummary {
  const RecentTableSummary({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    this.closedAt,
    required this.isHost,
    required this.players,
    this.pl,
  });

  final String id;
  final String name;
  final TableStatus status;
  final DateTime createdAt;
  final DateTime? closedAt;
  final bool isHost;
  final int players;
  final Decimal? pl;
}
