/// Configuração injetada via `--dart-define`.
///
/// Em Android emulator use `10.0.2.2` em vez de `localhost` — o emulador
/// trata o host como o próprio device.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.firebaseWebApiKey,
    required this.googleClientId,
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:3000/api',
      ),
      firebaseWebApiKey: String.fromEnvironment(
        'FIREBASE_WEB_API_KEY',
        defaultValue: 'AIzaSyB0x3m0__4h9wRKDzWgAUYAQCkcnzvA0NM',
      ),
      googleClientId: String.fromEnvironment(
        'GOOGLE_CLIENT_ID',
        defaultValue: '986946226655-4pn2a151tjin4bcpi9qfhsb835g9mj8g.apps.googleusercontent.com',
      ),
    );
  }

  final String apiBaseUrl;
  final String firebaseWebApiKey;
  final String googleClientId;
}
