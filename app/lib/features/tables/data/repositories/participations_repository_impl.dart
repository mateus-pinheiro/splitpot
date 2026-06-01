import 'package:decimal/decimal.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/repositories/participations_repository.dart';

class ParticipationsRepositoryImpl implements ParticipationsRepository {
  ParticipationsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<String> joinTable({
    required String tableId,
    Decimal? initialBuyIn,
  }) async {
    final json = await _api.post('/participations', body: {
      'tableId': tableId,
      if (initialBuyIn != null)
        'initialBuyIn': double.parse(initialBuyIn.toString()),
    });
    return json['id'] as String;
  }

  @override
  Future<String> addRegisteredPlayer({
    required String tableId,
    required String userId,
    Decimal? initialBuyIn,
  }) async {
    final json = await _api.post('/participations', body: {
      'tableId': tableId,
      'userId': userId,
      if (initialBuyIn != null)
        'initialBuyIn': double.parse(initialBuyIn.toString()),
    });
    return json['id'] as String;
  }

  @override
  Future<String> addGuestPlayer({
    required String tableId,
    required String name,
    required String pixKey,
    Decimal? initialBuyIn,
  }) async {
    final json = await _api.post('/participations', body: {
      'tableId': tableId,
      'guestName': name,
      'guestPixKey': pixKey,
      if (initialBuyIn != null)
        'initialBuyIn': double.parse(initialBuyIn.toString()),
    });
    return json['id'] as String;
  }

  @override
  Future<void> leaveTable({required String participationId}) async {
    await _api.delete('/participations/$participationId');
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
  Future<void> updateBuyIn({
    required String participationId,
    required String buyInId,
    required Decimal amount,
  }) async {
    await _api
        .patch('/participations/$participationId/buy-ins/$buyInId', body: {
      'amount': double.parse(amount.toString()),
    });
  }

  @override
  Future<void> removeBuyIn({
    required String participationId,
    required String buyInId,
  }) async {
    await _api.delete('/participations/$participationId/buy-ins/$buyInId');
  }

  @override
  Future<void> setCashOut({
    required String participationId,
    required Decimal amount,
    bool skipAutoClose = false,
  }) async {
    final path = skipAutoClose
        ? '/participations/$participationId/cash-out?skipAutoClose=true'
        : '/participations/$participationId/cash-out';
    await _api.put(path, body: {
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
