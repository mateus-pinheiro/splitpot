import 'package:decimal/decimal.dart';

import 'table_status.dart';

/// Visão pública/mínima de uma mesa — basta para a tela de pre-join
/// (`GET /tables/:id/preview`). Não traz PIX, buy-ins, cash-outs nem
/// listas de participantes.
class TablePreview {
  const TablePreview({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.minBuyIn,
    required this.status,
    required this.ownerName,
    required this.participantsCount,
  });

  final String id;
  final String ownerId;
  final String name;
  final Decimal minBuyIn;
  final TableStatus status;
  final String ownerName;
  final int participantsCount;
}
