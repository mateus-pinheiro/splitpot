import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementação mock do [AuthRepository] para desenvolvimento sem backend.
///
/// Simula latência de rede e retorna um usuário fixo. Será substituída pela
/// implementação real (Firebase + API) quando o backend estiver pronto.
class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  Future<User?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Future<User?> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    _currentUser = const User(
      id: 'mock-user-1',
      email: 'mateus@splitpot.app',
      name: 'Mateus Pinheiro',
      pixKey: 'mateus@splitpot.app',
    );
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}
