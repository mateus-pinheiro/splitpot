import '../entities/user.dart';

/// Contrato do repositório de autenticação.
///
/// Implementações vivem na camada de data (mock, Firebase + backend, etc.).
abstract class AuthRepository {
  /// Usuário atual persistido (null se não autenticado).
  Future<User?> getCurrentUser();

  /// Executa o fluxo de login com Google.
  ///
  /// Retorna o `User` se já tiver perfil completo (name/pixKey) no backend.
  /// Retorna `null` se o login foi bem-sucedido mas o perfil ainda precisa
  /// ser completado (primeiro acesso).
  Future<User?> signInWithGoogle();

  Future<void> signOut();
}
