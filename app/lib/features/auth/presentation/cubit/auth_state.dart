import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.authenticating() = AuthAuthenticating;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;
  const factory AuthState.needsProfile({required String suggestedName}) =
      AuthNeedsProfile;
  const factory AuthState.updatingProfile({required String suggestedName}) =
      AuthUpdatingProfile;
  const factory AuthState.error(Failure failure) = AuthError;
}
