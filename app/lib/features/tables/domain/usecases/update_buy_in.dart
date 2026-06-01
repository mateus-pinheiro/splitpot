import 'package:decimal/decimal.dart';

import '../repositories/participations_repository.dart';

class UpdateBuyIn {
  const UpdateBuyIn(this._repository);

  final ParticipationsRepository _repository;

  Future<void> call({
    required String participationId,
    required String buyInId,
    required Decimal amount,
  }) =>
      _repository.updateBuyIn(
        participationId: participationId,
        buyInId: buyInId,
        amount: amount,
      );
}
