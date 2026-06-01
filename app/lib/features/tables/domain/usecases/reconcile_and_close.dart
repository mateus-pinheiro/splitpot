import '../repositories/tables_repository.dart';

class ReconcileAndClose {
  const ReconcileAndClose(this._repository);

  final TablesRepository _repository;

  Future<CloseTableResult> call(
    String tableId,
    ReconcileStrategy strategy,
  ) =>
      _repository.reconcileAndClose(tableId, strategy);
}
