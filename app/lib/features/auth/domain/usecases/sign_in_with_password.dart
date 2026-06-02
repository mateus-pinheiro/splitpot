import '../repositories/auth_repository.dart';

/// Login com email e senha via Firebase Identity Toolkit.
/// O resultado chega pelo stream `AuthRepository.signInOutcomes`.
class SignInWithPassword {
  const SignInWithPassword(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) {
    return _repository.signInWithPassword(email: email, password: password);
  }
}
