import 'user.dart';

/// Resultado de um login: ou o perfil já existe no backend, ou ainda
/// precisa ser completado (primeiro acesso).
sealed class SignInOutcome {
  const SignInOutcome();
}

class SignInAuthenticated extends SignInOutcome {
  const SignInAuthenticated(this.user);
  final User user;
}

class SignInNeedsProfile extends SignInOutcome {
  const SignInNeedsProfile({required this.suggestedName});
  final String suggestedName;
}
