import 'package:decimal/decimal.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/action_requests_repository.dart';
import '../dto/action_request_dto.dart';

class ActionRequestsRepositoryImpl implements ActionRequestsRepository {
  ActionRequestsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<ActionRequest> requestAction({
    required String participationId,
    required ActionType type,
    Decimal? amount,
  }) async {
    final json = await _api.post('/action-requests', body: {
      'participationId': participationId,
      'type': _typeToString(type),
      if (amount != null) 'amount': double.parse(amount.toString()),
    });
    return ActionRequestDto.fromJson(json);
  }

  @override
  Future<void> approve(String requestId) async {
    await _api.post('/action-requests/$requestId/approve');
  }

  @override
  Future<void> reject(String requestId) async {
    await _api.post('/action-requests/$requestId/reject');
  }

  static String _typeToString(ActionType type) {
    switch (type) {
      case ActionType.buyin:
        return 'BUYIN';
      case ActionType.rebuy:
        return 'REBUY';
      case ActionType.leave:
        return 'LEAVE';
      case ActionType.rejoin:
        return 'REJOIN';
    }
  }
}
