import '../repositories/settlements_repository.dart';

class ConfirmSettlement {
  const ConfirmSettlement(this._repository);

  final SettlementsRepository _repository;

  Future<void> call(String settlementId) => _repository.confirm(settlementId);
}
