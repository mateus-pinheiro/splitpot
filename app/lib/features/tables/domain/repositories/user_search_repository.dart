import '../entities/user_summary.dart';

abstract class UserSearchRepository {
  /// Busca usuários cadastrados por nome ou email. Retorna no máximo 10.
  /// Backend exige `q` com pelo menos 2 caracteres; abaixo disso retorna [].
  Future<List<UserSummary>> search(String query);
}
