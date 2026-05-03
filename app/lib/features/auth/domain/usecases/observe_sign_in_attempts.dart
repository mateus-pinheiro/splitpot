import '../repositories/auth_repository.dart';

/// Emite um evento sempre que um sign-in começa a ser processado.
/// Usado pelo [AuthCubit] para emitir [AuthAuthenticating] antes que
/// o resultado chegue via [ObserveSignInOutcomes].
class ObserveSignInAttempts {
  const ObserveSignInAttempts(this._repository);

  final AuthRepository _repository;

  Stream<void> call() => _repository.signInAttempted;
}
