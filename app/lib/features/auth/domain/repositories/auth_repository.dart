import '../entities/entities.dart';

/// Contrato do repositório de autenticação.
///
/// Suporta 4 fluxos: Google, Apple, login email/senha e cadastro
/// email/senha. Os 3 primeiros são event-driven (resultado chega por
/// [signInOutcomes]); o cadastro é orquestrado por
/// [signUpAndCompleteProfile] pra evitar estado intermediário onde
/// a sessão Firebase existe mas o backend ainda não foi provisionado.
abstract class AuthRepository {
  /// Usuário atual persistido no backend (null se não autenticado OU
  /// autenticado no Firebase mas ainda sem perfil completo).
  Future<User?> getCurrentUser();

  /// Dispara o fluxo de Google Sign-In (mobile abre o picker; web é
  /// no-op porque o botão renderizado pelo próprio Google é quem inicia).
  Future<void> startGoogleSignIn();

  /// Dispara o diálogo nativo de Sign in with Apple (iOS).
  Future<void> startAppleSignIn();

  /// Login com email + senha.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  /// Cadastro email/senha + provisionamento do perfil no backend.
  /// Idempotente do ponto de vista da UI: ou volta um [User] completo
  /// ou lança erro.
  Future<User> signUpAndCompleteProfile({
    required String email,
    required String password,
    required String name,
    required String pixKey,
  });

  /// Descobre se o email já está cadastrado e quais providers estão
  /// vinculados — usado pra rotear o usuário direto pro provider correto.
  Future<EmailProvidersLookup> lookupEmailProviders(String email);

  /// Resultado de cada login bem-sucedido (ou erro via onError).
  Stream<SignInOutcome> get signInOutcomes;

  /// Emite um evento quando um sign-in começa a ser processado
  /// (credenciais obtidas do provider, antes da chamada ao backend).
  /// Usado para emitir [AuthAuthenticating] antes que o resultado
  /// chegue via [signInOutcomes].
  Stream<void> get signInAttempted;

  /// Persiste o perfil no backend (provisiona se ainda não existe).
  Future<User> updateProfile({required String name, required String pixKey});

  Future<void> signOut();
}
