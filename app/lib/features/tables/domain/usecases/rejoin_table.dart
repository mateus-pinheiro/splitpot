import 'package:decimal/decimal.dart';

import '../repositories/participations_repository.dart';

class RejoinTable {
  const RejoinTable(this._repository);

  final ParticipationsRepository _repository;

  Future<void> call({
    required String participationId,
    required Decimal amount,
  }) =>
      _repository.rejoin(participationId: participationId, amount: amount);
}
