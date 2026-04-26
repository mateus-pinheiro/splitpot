import 'package:decimal/decimal.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/repositories/participations_repository.dart';

class ParticipationsRepositoryImpl implements ParticipationsRepository {
  ParticipationsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<void> joinTable({
    required String tableId,
    Decimal? initialBuyIn,
  }) async {
    await _api.post('/participations', body: {
      'tableId': tableId,
      if (initialBuyIn != null)
        'initialBuyIn': double.parse(initialBuyIn.toString()),
    });
  }

  @override
  Future<void> addBuyIn({
    required String participationId,
    required Decimal amount,
  }) async {
    await _api.post('/participations/$participationId/buy-ins', body: {
      'amount': double.parse(amount.toString()),
    });
  }

  @override
  Future<void> setCashOut({
    required String participationId,
    required Decimal amount,
  }) async {
    await _api.put('/participations/$participationId/cash-out', body: {
      'amount': double.parse(amount.toString()),
    });
  }

  @override
  Future<void> rejoin({
    required String participationId,
    required Decimal amount,
  }) async {
    await _api.post('/participations/$participationId/rejoin', body: {
      'amount': double.parse(amount.toString()),
    });
  }
}
