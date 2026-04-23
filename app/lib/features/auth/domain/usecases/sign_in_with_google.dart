import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<User?> call() => _repository.signInWithGoogle();
}
