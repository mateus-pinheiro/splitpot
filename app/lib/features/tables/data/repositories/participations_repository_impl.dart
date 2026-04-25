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
}
