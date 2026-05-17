import '../../../../core/network/network.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dto/user_dto.dart';
import '../services/services.dart';

/// Implementação de [AuthRepository] sobre Google Sign-In + backend Nest.
///
/// Transforma credenciais do Firebase em `SignInOutcome` consultando
/// `GET /users/me`: se o perfil existe → [SignInAuthenticated]; se 404 →
/// [SignInNeedsProfile].
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
  Future<void> startSignIn() => _firebase.triggerSignIn();

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
      // Queremos limpar sessão local mesmo se a chamada ao Google falhar.
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
