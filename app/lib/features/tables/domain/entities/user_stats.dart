import 'package:decimal/decimal.dart';

import 'table_status.dart';

/// Estatísticas agregadas do usuário usadas na home.
class UserStats {
  const UserStats({
    required this.pnlTotal,
    required this.mesas,
    required this.wins,
    required this.recents,
    required this.history,
    required this.debts,
    required this.receivables,
  });

  final Decimal pnlTotal;
  final int mesas;
  final int wins;
  final List<RecentTableSummary> recents;
  final List<RecentTableSummary> history;
  final List<DebtItem> debts;
  final List<ReceivableItem> receivables;
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
    this.hasPendingSettlements = false,
  });

  final String id;
  final String name;
  final TableStatus status;
  final DateTime createdAt;
  final DateTime? closedAt;
  final bool isHost;
  final int players;
  final Decimal? pl;
  final bool hasPendingSettlements;
}

/// Settlement pendente em que o usuário é o pagador.
class DebtItem {
  const DebtItem({
    required this.id,
    required this.amount,
    this.toUserId,
    required this.toName,
    this.toPixKey,
    required this.tableId,
    required this.tableName,
    this.pixCopiaECola,
  });

  final String id;
  final Decimal amount;

  /// Nulo quando o destinatário é convidado (sem conta).
  final String? toUserId;
  final String toName;

  /// Pode ser nulo se o destinatário não tem PIX cadastrado (raro pra
  /// settlements abertos depois da Fase 2; ainda assim defensivo).
  final String? toPixKey;
  final String tableId;
  final String tableName;
  final String? pixCopiaECola;

  bool get isToGuest => toUserId == null;
}

/// Settlement pendente em que o usuário é o recebedor.
class ReceivableItem {
  const ReceivableItem({
    required this.id,
    required this.amount,
    this.fromUserId,
    required this.fromName,
    required this.tableId,
    required this.tableName,
  });

  final String id;
  final Decimal amount;

  /// Nulo quando o pagador é convidado.
  final String? fromUserId;
  final String fromName;
  final String tableId;
  final String tableName;

  bool get isFromGuest => fromUserId == null;
}
