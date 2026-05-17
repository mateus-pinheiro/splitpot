import 'package:decimal/decimal.dart';

import '../entities/entities.dart';

abstract class ActionRequestsRepository {
  Future<ActionRequest> requestAction({
    required String participationId,
    required ActionType type,
    Decimal? amount,
  });

  Future<void> approve(String requestId);

  Future<void> reject(String requestId);
}
