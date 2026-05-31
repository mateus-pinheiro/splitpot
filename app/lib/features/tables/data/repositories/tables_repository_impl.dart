import 'package:decimal/decimal.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/tables_repository.dart';
import '../../domain/usecases/calculate_settlements.dart';
import '../dto/dto.dart';

/// Implementação de [TablesRepository] sobre os endpoints Nest
/// (`/tables`, `/settlements`, `/users/me/stats`).
class TablesRepositoryImpl implements TablesRepository {
  TablesRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<PokerTable> createTable({
    required String name,
    required Decimal minBuyIn,
    bool joinAsPlayer = false,
    Decimal? initialBuyIn,
  }) async {
    final json = await _api.post('/tables', body: {
      'name': name,
      'minBuyIn': double.parse(minBuyIn.toString()),
      if (joinAsPlayer) 'joinAsPlayer': true,
      if (initialBuyIn != null)
        'initialBuyIn': double.parse(initialBuyIn.toString()),
    });
    return TableDto.fromJson(json);
  }

  @override
  Future<PokerTable> getTable(String id) async {
    final json = await _api.get('/tables/$id');
    return TableDto.fromJson(json);
  }

  @override
  Future<TablePreview> getTablePreview(String id) async {
    final json = await _api.get('/tables/$id/preview');
    return TablePreviewDto.fromJson(json);
  }

  @override
  Future<CloseTableResult> closeTable(String id) async {
    final closeJson = await _api.post('/tables/$id/close');
    return _closeResult(closeJson);
  }

  @override
  Future<CloseTableResult> reconcileAndClose(
    String id,
    ReconcileStrategy strategy,
  ) async {
    final closeJson = await _api.post(
      '/tables/$id/reconcile-and-close',
      body: {
        'strategy': switch (strategy) {
          ReconcileStrategy.hostAbsorb => 'HOST_ABSORB',
          ReconcileStrategy.splitEvenly => 'SPLIT_EVENLY',
        },
      },
    );
    return _closeResult(closeJson);
  }

  CloseTableResult _closeResult(Map<String, dynamic> closeJson) {
    final table = TableDto.fromJson(closeJson);
    final settlementsJson =
        closeJson['settlements'] as List<dynamic>? ?? const [];
    final settlements = settlementsJson
        .map((e) => SettlementDto.toDraft(e as Map<String, dynamic>))
        .toList(growable: false);
    return CloseTableResult(
      table: table,
      settlements: settlements,
      divergence: tableDivergence(table),
    );
  }

  @override
  Future<UserStats> getUserStats() async {
    final json = await _api.get('/users/me/stats');
    return UserStatsDto.fromJson(json);
  }
}
