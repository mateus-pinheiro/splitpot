import '../repositories/settlements_repository.dart';

class ConfirmSettlementOnBehalf {
  const ConfirmSettlementOnBehalf(this._repository);

  final SettlementsRepository _repository;

  Future<void> call(String settlementId) =>
      _repository.confirmOnBehalf(settlementId);
}
