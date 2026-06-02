import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Cadastro email/senha + provisionamento de perfil no backend numa
/// chamada atômica do ponto de vista da UI. Cria o usuário no Firebase
/// e logo em seguida chama `POST /users/me` — se a segunda falhar o
/// cubit ainda pode reagir, mas o usuário Firebase já existe (idempotência
/// fica por conta de futuras tentativas com o mesmo email).
class SignUpAndCompleteProfile {
  const SignUpAndCompleteProfile(this._repository);

  final AuthRepository _repository;

  Future<User> call({
    required String email,
    required String password,
    required String name,
    required String pixKey,
  }) {
    return _repository.signUpAndCompleteProfile(
      email: email,
      password: password,
      name: name,
      pixKey: pixKey,
    );
  }
}
