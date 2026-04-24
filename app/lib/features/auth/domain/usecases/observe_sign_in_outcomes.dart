import '../entities/sign_in_outcome.dart';
import '../repositories/auth_repository.dart';

class ObserveSignInOutcomes {
  const ObserveSignInOutcomes(this._repository);

  final AuthRepository _repository;

  Stream<SignInOutcome> call() => _repository.signInOutcomes;
}
