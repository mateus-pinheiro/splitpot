import '../entities/poker_table.dart';
import '../repositories/tables_repository.dart';

class GetTable {
  const GetTable(this._repository);

  final TablesRepository _repository;

  Future<PokerTable> call(String id) => _repository.getTable(id);
}
