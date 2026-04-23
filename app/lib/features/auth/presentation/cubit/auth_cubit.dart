import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/update_profile.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required SignInWithGoogle signInWithGoogle,
    required GetCurrentUser getCurrentUser,
    required UpdateProfile updateProfile,
    required SignOut signOut,
  })  : _signInWithGoogle = signInWithGoogle,
        _getCurrentUser = getCurrentUser,
        _updateProfile = updateProfile,
        _signOut = signOut,
        super(const AuthState.unauthenticated());

  final SignInWithGoogle _signInWithGoogle;
  final GetCurrentUser _getCurrentUser;
  final UpdateProfile _updateProfile;
  final SignOut _signOut;

  Future<void> bootstrap() async {
    try {
      final user = await _getCurrentUser();
      if (user == null) {
        emit(const AuthState.unauthenticated());
      } else {
        emit(AuthState.authenticated(user));
      }
    } on Object catch (_) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthState.authenticating());
    try {
      final user = await _signInWithGoogle();
      if (user == null) {
        // Primeiro login: Google devolveu dados básicos, mas PIX ainda
        // não foi informado. Por ora o nome sugerido é fixo (mock).
        emit(const AuthState.needsProfile(suggestedName: 'Mateus Pinheiro'));
      } else {
        emit(AuthState.authenticated(user));
      }
    } on Object catch (e) {
      emit(AuthState.error(Failure.unexpected(message: e.toString())));
    }
  }

  Future<void> completeProfile({required String name, required String pixKey}) async {
    final current = state;
    final suggestedName = current is AuthNeedsProfile
        ? current.suggestedName
        : current is AuthUpdatingProfile
            ? current.suggestedName
            : name;
    emit(AuthState.updatingProfile(suggestedName: suggestedName));
    try {
      final user = await _updateProfile(name: name, pixKey: pixKey);
      emit(AuthState.authenticated(user));
    } on Object catch (e) {
      emit(AuthState.error(Failure.unexpected(message: e.toString())));
    }
  }

  Future<void> signOut() async {
    try {
      await _signOut();
    } finally {
      emit(const AuthState.unauthenticated());
    }
  }
}
