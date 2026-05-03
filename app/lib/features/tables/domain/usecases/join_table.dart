import '../repositories/participations_repository.dart';

class JoinTable {
  const JoinTable(this._repository);

  final ParticipationsRepository _repository;

  Future<String> call(String tableId) =>
      _repository.joinTable(tableId: tableId);
}
