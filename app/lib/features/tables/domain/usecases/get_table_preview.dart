import '../entities/table_preview.dart';
import '../repositories/tables_repository.dart';

class GetTablePreview {
  const GetTablePreview(this._repository);

  final TablesRepository _repository;

  Future<TablePreview> call(String tableId) =>
      _repository.getTablePreview(tableId);
}
