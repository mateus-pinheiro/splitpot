import '../repositories/tables_repository.dart';

class CloseTable {
  const CloseTable(this._repository);

  final TablesRepository _repository;

  Future<CloseTableResult> call(String tableId) =>
      _repository.closeTable(tableId);
}
