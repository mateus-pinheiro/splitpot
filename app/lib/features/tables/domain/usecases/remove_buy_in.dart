import '../repositories/participations_repository.dart';

class RemoveBuyIn {
  const RemoveBuyIn(this._repository);

  final ParticipationsRepository _repository;

  Future<void> call({
    required String participationId,
    required String buyInId,
  }) =>
      _repository.removeBuyIn(
        participationId: participationId,
        buyInId: buyInId,
      );
}
