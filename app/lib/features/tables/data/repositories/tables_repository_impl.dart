import 'package:decimal/decimal.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/repositories/tables_repository.dart';
import '../../domain/usecases/calculate_settlements.dart';
import '../dto/settlement_dto.dart';
import '../dto/table_dto.dart';

/// Implementação de [TablesRepository] sobre os endpoints Nest
/// (`/tables`, `/settlements`).
class TablesRepositoryImpl implements TablesRepository {
  TablesRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<PokerTable> createTable({
    required String name,
    required Decimal minBuyIn,
  }) async {
    final json = await _api.post('/tables', body: {
      'name': name,
      'minBuyIn': double.parse(minBuyIn.toString()),
    });
    return TableDto.fromJson(json);
  }

  @override
  Future<PokerTable> getTable(String id) async {
    final json = await _api.get('/tables/$id');
    return TableDto.fromJson(json);
  }

  @override
  Future<CloseTableResult> closeTable(String id) async {
    final closeJson = await _api.post('/tables/$id/close');
    final table = TableDto.fromJson(closeJson);
    final settlementsJson = closeJson['settlements'] as List<dynamic>? ?? const [];
    final settlements = settlementsJson
        .map((e) => SettlementDto.toDraft(e as Map<String, dynamic>))
        .toList(growable: false);
    return CloseTableResult(
      table: table,
      settlements: settlements,
      divergence: tableDivergence(table),
    );
  }
}
