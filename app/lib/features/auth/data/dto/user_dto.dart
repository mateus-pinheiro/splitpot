import '../../domain/entities/user.dart';

/// Mapeia a resposta de `/api/users/me` e `POST /api/users/me` pra entidade.
class UserDto {
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      pixKey: json['pixKey'] as String,
    );
  }
}
