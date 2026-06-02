import 'auth_provider.dart';

/// Resultado do lookup de providers (`GET /auth/providers` no backend):
/// informa se o email já está cadastrado e quais providers estão vinculados.
class EmailProvidersLookup {
  const EmailProvidersLookup({
    required this.registered,
    required this.providers,
  });

  final bool registered;
  final List<AuthProvider> providers;

  bool get hasGoogle => providers.contains(AuthProvider.google);
  bool get hasApple => providers.contains(AuthProvider.apple);
  bool get hasPassword => providers.contains(AuthProvider.password);
}
