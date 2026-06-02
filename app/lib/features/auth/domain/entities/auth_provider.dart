/// Provedor de identidade usado pra autenticar.
///
/// Reflete o `providerId` do Firebase Identity Toolkit:
/// `google.com`, `apple.com`, `password`.
enum AuthProvider {
  google,
  apple,
  password;

  /// String que o Firebase espera em `signInWithIdp.providerId`.
  String get firebaseProviderId => switch (this) {
        AuthProvider.google => 'google.com',
        AuthProvider.apple => 'apple.com',
        AuthProvider.password => 'password',
      };

  static AuthProvider? fromFirebaseId(String id) => switch (id) {
        'google.com' => AuthProvider.google,
        'apple.com' => AuthProvider.apple,
        'password' => AuthProvider.password,
        _ => null,
      };
}
