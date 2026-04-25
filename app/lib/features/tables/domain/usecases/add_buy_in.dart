import 'package:decimal/decimal.dart';

import '../repositories/participations_repository.dart';

class AddBuyIn {
  const AddBuyIn(this._repository);

  final ParticipationsRepository _repository;

  Future<void> call({
    required String participationId,
    required Decimal amount,
  }) =>
      _repository.addBuyIn(participationId: participationId, amount: amount);
}
