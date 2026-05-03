import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'action_request.dart';
import 'table_participation.dart';
import 'table_status.dart';

part 'poker_table.freezed.dart';

/// Mesa de poker.
///
/// Nomeada `PokerTable` (não `Table`) porque `Table` colide com o widget
/// `Table` do Flutter e com o tipo `Table` gerado pelo Prisma — o conflito
/// de nome atrapalhava imports e autocomplete.
@freezed
abstract class PokerTable with _$PokerTable {
  const factory PokerTable({
    required String id,
    required String ownerId,
    required String name,
    required Decimal minBuyIn,
    required TableStatus status,
    required DateTime createdAt,
    DateTime? closedAt,
    @Default(<TableParticipation>[]) List<TableParticipation> participations,
    @Default(<ActionRequest>[]) List<ActionRequest> pendingRequests,
  }) = _PokerTable;
}
