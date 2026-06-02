import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_provider.dart';
import '../../domain/entities/sign_in_outcome.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required SignInWithGoogle signInWithGoogle,
    required SignInWithApple signInWithApple,
    required SignInWithPassword signInWithPassword,
    required SignUpAndCompleteProfile signUpAndCompleteProfile,
    required ObserveSignInOutcomes observeSignInOutcomes,
    required ObserveSignInAttempts observeSignInAttempts,
    required GetCurrentUser getCurrentUser,
    required UpdateProfile updateProfile,
    required SignOut signOut,
  })  : _signInWithGoogle = signInWithGoogle,
        _signInWithApple = signInWithApple,
        _signInWithPassword = signInWithPassword,
        _signUpAndCompleteProfile = signUpAndCompleteProfile,
        _getCurrentUser = getCurrentUser,
        _updateProfile = updateProfile,
        _signOut = signOut,
        super(const AuthState.unauthenticated()) {
    _outcomesSub = observeSignInOutcomes().listen(
      _onOutcome,
      onError: _onOutcomeError,
    );
    _attemptsSub = observeSignInAttempts().listen(
      (_) => emit(const AuthState.authenticating()),
    );
  }

  final SignInWithGoogle _signInWithGoogle;
  final SignInWithApple _signInWithApple;
  final SignInWithPassword _signInWithPassword;
  final SignUpAndCompleteProfile _signUpAndCompleteProfile;
  final GetCurrentUser _getCurrentUser;
  final UpdateProfile _updateProfile;
  final SignOut _signOut;
  late final StreamSubscription<SignInOutcome> _outcomesSub;
  late final StreamSubscription<void> _attemptsSub;

  Future<void> bootstrap() async {
    emit(const AuthState.authenticating());
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
      await _signInWithGoogle();
    } on Object catch (e) {
      emit(AuthState.error(_asFailure(e)));
    }
  }

  Future<void> signInWithApple() async {
    emit(const AuthState.authenticating());
    try {
      await _signInWithApple();
    } on Object catch (e) {
      emit(AuthState.error(_asFailure(e)));
    }
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.authenticating());
    try {
      await _signInWithPassword(email: email, password: password);
    } on Object catch (e) {
      emit(AuthState.error(_asFailure(e)));
    }
  }

  /// Email digitado no login não existe no Firebase — leva pro fluxo de
  /// cadastro mantendo email/senha em estado transitório pra
  /// `CompleteProfileView` reaproveitar.
  void beginPasswordSignup({
    required String email,
    required String password,
    required String suggestedName,
  }) {
    emit(AuthState.needsProfile(
      suggestedName: suggestedName,
      provider: AuthProvider.password,
      draftEmail: email,
      draftPassword: password,
    ));
  }

  /// Cancela um fluxo de cadastro password sem submeter (back na
  /// CompleteProfile). Limpa o draft pra evitar reusar email/senha
  /// stale numa próxima entrada.
  void cancelPendingSignup() {
    if (state is AuthNeedsProfile || state is AuthUpdatingProfile) {
      emit(const AuthState.unauthenticated());
    }
  }

  /// Submit de cadastro vindo do fluxo password: cria o usuário Firebase
  /// e provisiona perfil no backend numa chamada só.
  Future<void> signUpAndCompleteProfile({
    required String name,
    required String pixKey,
  }) async {
    final current = state;
    if (current is! AuthNeedsProfile ||
        current.provider != AuthProvider.password ||
        current.draftEmail == null ||
        current.draftPassword == null) {
      emit(AuthState.error(
        Failure.unexpected(
          message: 'Sessão de cadastro inválida. Tente novamente.',
        ),
      ));
      return;
    }
    emit(AuthState.updatingProfile(
      suggestedName: current.suggestedName,
      provider: AuthProvider.password,
    ));
    try {
      final user = await _signUpAndCompleteProfile(
        email: current.draftEmail!,
        password: current.draftPassword!,
        name: name,
        pixKey: pixKey,
      );
      emit(AuthState.authenticated(user));
    } on Object catch (e) {
      emit(AuthState.error(_asFailure(e)));
    }
  }

  /// Fluxo Google/Apple: usuário Firebase já existe, só falta `POST /users/me`.
  Future<void> completeProfile({
    required String name,
    required String pixKey,
  }) async {
    final current = state;
    final suggestedName = switch (current) {
      AuthNeedsProfile(:final suggestedName) => suggestedName,
      AuthUpdatingProfile(:final suggestedName) => suggestedName,
      _ => name,
    };
    final provider = switch (current) {
      AuthNeedsProfile(:final provider) => provider,
      AuthUpdatingProfile(:final provider) => provider,
      _ => AuthProvider.google,
    };
    emit(AuthState.updatingProfile(
      suggestedName: suggestedName,
      provider: provider,
    ));
    try {
      final user = await _updateProfile(name: name, pixKey: pixKey);
      emit(AuthState.authenticated(user));
    } on Object catch (e) {
      emit(AuthState.error(_asFailure(e)));
    }
  }

  /// Atualiza nome/PIX de um usuário já autenticado (fluxo de edição de
  /// perfil). Diferente de [completeProfile], não passa por
  /// `AuthUpdatingProfile` para não acionar o redirect para
  /// `/complete-profile`. Relança erros para que a view exiba feedback local.
  Future<User> editProfile({
    required String name,
    required String pixKey,
  }) async {
    final user = await _updateProfile(name: name, pixKey: pixKey);
    emit(AuthState.authenticated(user));
    return user;
  }

  Future<void> signOut() async {
    try {
      await _signOut();
    } finally {
      emit(const AuthState.unauthenticated());
    }
  }

  @override
  Future<void> close() async {
    await _outcomesSub.cancel();
    await _attemptsSub.cancel();
    return super.close();
  }

  void _onOutcome(SignInOutcome outcome) {
    switch (outcome) {
      case SignInAuthenticated(:final user):
        emit(AuthState.authenticated(user));
      case SignInNeedsProfile(:final suggestedName, :final provider):
        emit(AuthState.needsProfile(
          suggestedName: suggestedName,
          provider: provider,
        ));
    }
  }

  void _onOutcomeError(Object error, StackTrace _) {
    emit(AuthState.error(_asFailure(error)));
  }

  Failure _asFailure(Object error) {
    if (error is ApiException) return error.failure;
    return Failure.unexpected(message: error.toString());
  }
}
