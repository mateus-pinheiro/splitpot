import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfile {
  const UpdateProfile(this._repository);

  final AuthRepository _repository;

  Future<User> call({required String name, required String pixKey}) {
    return _repository.updateProfile(name: name, pixKey: pixKey);
  }
}
