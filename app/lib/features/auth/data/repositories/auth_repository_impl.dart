import '../../../../core/network/network.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dto/user_dto.dart';
import '../services/services.dart';

/// Implementação de [AuthRepository] sobre Firebase Identity Toolkit
/// (Google/Apple/email-senha) + backend Nest.
///
/// Transforma credenciais Firebase em [SignInOutcome] consultando
/// `GET /users/me`: se o perfil existe → [SignInAuthenticated]; se 404 →
/// [SignInNeedsProfile] com o provider detectado.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required FirebaseRestAuthService firebaseService,
    required FirebaseTokenStore tokenStore,
  })  : _api = apiClient,
        _firebase = firebaseService,
        _tokenStore = tokenStore;

  final ApiClient _api;
  final FirebaseRestAuthService _firebase;
  final FirebaseTokenStore _tokenStore;

  String? _pendingEmail;

  @override
  Future<User?> getCurrentUser() async {
    if (await _tokenStore.getIdToken() == null) return null;
    final json = await _api.getOrNull('/users/me');
    if (json == null) return null;
    return UserDto.fromJson(json);
  }

  @override
  Future<void> startGoogleSignIn() => _firebase.triggerGoogleSignIn();

  @override
  Future<void> startAppleSignIn() => _firebase.triggerAppleSignIn();

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _firebase.signInWithPassword(email: email, password: password);
  }

  /// Lookup de providers via backend (`GET /auth/providers`), que usa o
  /// Firebase Admin SDK como fonte de verdade. Evitamos o
  /// `accounts:createAuthUri` do client porque ele responde
  /// `registered: false` para todo email quando a Email Enumeration
  /// Protection está ligada — o que jogava logins legítimos pro fluxo de
  /// cadastro.
  @override
  Future<EmailProvidersLookup> lookupEmailProviders(String email) async {
    final json = await _api.get('/auth/providers', query: {'email': email});
    final registered = json['registered'] == true;
    final all =
        (json['providers'] as List?)?.cast<String>() ?? const <String>[];
    final providers = all
        .map(AuthProvider.fromFirebaseId)
        .whereType<AuthProvider>()
        .toList(growable: false);
    return EmailProvidersLookup(registered: registered, providers: providers);
  }

  @override
  Future<User> signUpAndCompleteProfile({
    required String email,
    required String password,
    required String name,
    required String pixKey,
  }) async {
    final creds = await _firebase.signUpWithPassword(
      email: email,
      password: password,
    );
    _tokenStore.set(creds.idToken);
    _pendingEmail = creds.email;
    // Reutiliza o caminho de POST /users/me — o backend faz upsert por
    // firebaseUid, então o registro recém-criado no Firebase já vira
    // um User completo no nosso banco.
    return updateProfile(name: name, pixKey: pixKey);
  }

  @override
  Stream<void> get signInAttempted => _firebase.credentials.map((_) {});

  @override
  Stream<SignInOutcome> get signInOutcomes {
    return _firebase.credentials.asyncMap((credentials) async {
      _tokenStore.set(credentials.idToken);
      _pendingEmail = credentials.email;

      final profile = await _api.getOrNull('/users/me');
      if (profile != null) {
        return SignInAuthenticated(UserDto.fromJson(profile));
      }
      return SignInNeedsProfile(
        suggestedName:
            credentials.name ?? _deriveNameFromEmail(credentials.email),
        provider: credentials.provider,
      );
    });
  }

  @override
  Future<User> updateProfile({
    required String name,
    required String pixKey,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'pixKey': pixKey,
      if (_pendingEmail != null) 'email': _pendingEmail,
    };
    final json = await _api.post('/users/me', body: body);
    return UserDto.fromJson(json);
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebase.signOut();
    } on ApiException {
      // Queremos limpar sessão local mesmo se a chamada ao provider falhar.
    }
    _tokenStore.clear();
    _pendingEmail = null;
  }

  String _deriveNameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return '';
    return local[0].toUpperCase() + local.substring(1);
  }
}
