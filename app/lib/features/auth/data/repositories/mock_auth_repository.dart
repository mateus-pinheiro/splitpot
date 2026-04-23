import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementação mock do [AuthRepository] para desenvolvimento sem backend.
///
/// Simula latência de rede e mantém o usuário em memória. Será substituída
/// pela implementação real (Firebase + API) quando o backend estiver pronto.
class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  /// Dados que o Google devolve no login. O PIX ainda precisa ser coletado
  /// na primeira sessão — por isso `signInWithGoogle` retorna `null` e
  /// guarda esse pending aqui.
  _PendingProfile? _pending;

  @override
  Future<User?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Future<User?> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    // Simula um primeiro login: Google devolve nome/email mas o PIX
    // ainda precisa ser informado pelo usuário.
    _pending = const _PendingProfile(
      id: 'mock-user-1',
      email: 'mateus@splitpot.app',
      name: 'Mateus Pinheiro',
    );
    return null;
  }

  @override
  Future<User> updateProfile({required String name, required String pixKey}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final pending = _pending;
    if (pending == null) {
      throw StateError('updateProfile chamado sem um login prévio');
    }
    final user = User(
      id: pending.id,
      email: pending.email,
      name: name,
      pixKey: pixKey,
    );
    _currentUser = user;
    _pending = null;
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _pending = null;
  }
}

class _PendingProfile {
  const _PendingProfile({
    required this.id,
    required this.email,
    required this.name,
  });

  final String id;
  final String email;
  final String name;
}
