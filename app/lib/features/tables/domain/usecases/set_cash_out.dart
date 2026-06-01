import 'package:decimal/decimal.dart';

import '../repositories/participations_repository.dart';

class SetCashOut {
  const SetCashOut(this._repository);

  final ParticipationsRepository _repository;

  Future<void> call({
    required String participationId,
    required Decimal amount,
    bool skipAutoClose = false,
  }) =>
      _repository.setCashOut(
        participationId: participationId,
        amount: amount,
        skipAutoClose: skipAutoClose,
      );
}
