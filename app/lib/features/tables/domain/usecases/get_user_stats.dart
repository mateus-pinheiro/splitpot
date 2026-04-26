import '../entities/user_stats.dart';
import '../repositories/tables_repository.dart';

class GetUserStats {
  const GetUserStats(this._repository);

  final TablesRepository _repository;

  Future<UserStats> call() => _repository.getUserStats();
}
