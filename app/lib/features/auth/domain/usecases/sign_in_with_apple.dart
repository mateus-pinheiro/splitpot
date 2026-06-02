import '../repositories/auth_repository.dart';

/// Dispara o diálogo nativo de Sign in with Apple (iOS).
/// O resultado chega pelo stream `AuthRepository.signInOutcomes`,
/// idêntico ao fluxo do Google.
class SignInWithApple {
  const SignInWithApple(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.startAppleSignIn();
}
