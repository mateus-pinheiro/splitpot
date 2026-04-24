import '../repositories/auth_repository.dart';

/// Dispara o fluxo de Google Sign-In. Em mobile abre o picker; em web
/// é no-op (o botão renderizado pelo Google é quem inicia o popup).
/// O resultado chega pelo stream `AuthRepository.signInOutcomes`.
class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.startSignIn();
}
