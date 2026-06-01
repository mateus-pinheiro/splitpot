import '../entities/entities.dart';
import '../repositories/tables_repository.dart';

class TransferHost {
  const TransferHost(this._repository);

  final TablesRepository _repository;

  Future<PokerTable> call({
    required String tableId,
    required String newOwnerId,
  }) =>
      _repository.transferHost(tableId: tableId, newOwnerId: newOwnerId);
}
