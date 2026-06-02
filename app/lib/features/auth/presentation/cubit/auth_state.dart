import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/auth_provider.dart';
import '../../domain/entities/user.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.authenticating() = AuthAuthenticating;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;

  /// Sessão Firebase ativa mas perfil ainda não provisionado no backend.
  /// `provider` indica de onde veio (Google/Apple → sem campo senha
  /// na tela de cadastro; password → senha já foi digitada no login
  /// e fica disponível em [draftPassword] pra evitar repetir).
  const factory AuthState.needsProfile({
    required String suggestedName,
    required AuthProvider provider,
    String? draftEmail,
    String? draftPassword,
  }) = AuthNeedsProfile;

  const factory AuthState.updatingProfile({
    required String suggestedName,
    required AuthProvider provider,
  }) = AuthUpdatingProfile;

  const factory AuthState.error(Failure failure) = AuthError;
}
