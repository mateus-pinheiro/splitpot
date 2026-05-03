import 'package:decimal/decimal.dart';

import '../entities/action_request.dart';
import '../entities/action_type.dart';
import '../repositories/action_requests_repository.dart';

class RequestAction {
  const RequestAction(this._repository);

  final ActionRequestsRepository _repository;

  Future<ActionRequest> call({
    required String participationId,
    required ActionType type,
    Decimal? amount,
  }) =>
      _repository.requestAction(
        participationId: participationId,
        type: type,
        amount: amount,
      );
}
