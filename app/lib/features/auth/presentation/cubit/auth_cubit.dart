import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/sign_in_outcome.dart';
import '../../domain/usecases/usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required SignInWithGoogle signInWithGoogle,
    required ObserveSignInOutcomes observeSignInOutcomes,
    required ObserveSignInAttempts observeSignInAttempts,
    required GetCurrentUser getCurrentUser,
    required UpdateProfile updateProfile,
    required SignOut signOut,
  })  : _signInWithGoogle = signInWithGoogle,
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
      // Em mobile o picker foi aberto; em web a UI já renderizou o
      // botão do Google. O resultado chega via stream em _onOutcome.
    } on Object catch (e) {
      emit(AuthState.error(_asFailure(e)));
    }
  }

  Future<void> completeProfile({required String name, required String pixKey}) async {
    final current = state;
    final suggestedName = switch (current) {
      AuthNeedsProfile(:final suggestedName) => suggestedName,
      AuthUpdatingProfile(:final suggestedName) => suggestedName,
      _ => name,
    };
    emit(AuthState.updatingProfile(suggestedName: suggestedName));
    try {
      final user = await _updateProfile(name: name, pixKey: pixKey);
      emit(AuthState.authenticated(user));
    } on Object catch (e) {
      emit(AuthState.error(_asFailure(e)));
    }
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
      case SignInNeedsProfile(:final suggestedName):
        emit(AuthState.needsProfile(suggestedName: suggestedName));
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
