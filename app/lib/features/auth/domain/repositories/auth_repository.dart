import '../entities/sign_in_outcome.dart';
import '../entities/user.dart';

/// Contrato do repositório de autenticação.
///
/// O fluxo de Google Sign-In é event-driven: em web não temos controle
/// pra abrir o popup programaticamente — o botão renderizado pelo
/// próprio Google é quem dispara. Em mobile [startSignIn] abre o picker.
/// Em ambos os casos o resultado chega por [signInOutcomes].
abstract class AuthRepository {
  /// Usuário atual persistido no backend (null se não autenticado OU
  /// autenticado no Firebase mas ainda sem perfil completo).
  Future<User?> getCurrentUser();

  /// Dispara o fluxo de login (mobile abre o picker; web é no-op).
  Future<void> startSignIn();

  /// Resultado de cada login bem-sucedido (ou erro via onError).
  Stream<SignInOutcome> get signInOutcomes;

  /// Persiste o perfil no backend (provisiona se ainda não existe).
  Future<User> updateProfile({required String name, required String pixKey});

  Future<void> signOut();
}
