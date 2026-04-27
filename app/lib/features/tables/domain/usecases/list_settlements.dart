import '../entities/settlement.dart';
import '../repositories/settlements_repository.dart';

class ListSettlements {
  const ListSettlements(this._repository);

  final SettlementsRepository _repository;

  Future<List<Settlement>> call(String tableId) =>
      _repository.listByTable(tableId);
}
