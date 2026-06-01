import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_summary.dart';
import '../../domain/repositories/user_search_repository.dart';

class UserSearchRepositoryImpl implements UserSearchRepository {
  UserSearchRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<UserSummary>> search(String query) async {
    if (query.trim().length < 2) return const [];
    final list = await _api.getList(
      '/users/search',
      query: {'q': query.trim()},
    );
    return list
        .map(
          (e) => UserSummary(
            id: (e as Map<String, dynamic>)['id'] as String,
            name: e['name'] as String,
            email: e['email'] as String,
          ),
        )
        .toList(growable: false);
  }
}
