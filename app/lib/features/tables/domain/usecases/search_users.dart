import '../entities/user_summary.dart';
import '../repositories/user_search_repository.dart';

class SearchUsers {
  const SearchUsers(this._repository);

  final UserSearchRepository _repository;

  Future<List<UserSummary>> call(String query) => _repository.search(query);
}
