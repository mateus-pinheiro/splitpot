import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';

/// Autentica via Google Sign-In e troca o idToken do Google por credenciais
/// Firebase via Identity Toolkit (`accounts:signInWithIdp`).
///
/// Fluxo event-driven unificado: em web o plugin só aceita o botão
/// renderizado pelo próprio Google (`renderButton()`), e a UI não tem
/// controle pra chamar `authenticate()` — a gente descobre o login
/// quando um `GoogleSignInAuthenticationEventSignIn` aparece no stream.
/// Em mobile o `authenticate()` também emite no mesmo stream, então a
/// pipeline é idêntica.
class FirebaseRestAuthService {
  FirebaseRestAuthService({
    required AppConfig config,
    GoogleSignIn? googleSignIn,
    http.Client? httpClient,
  })  : _config = config,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _http = httpClient ?? http.Client();

  final AppConfig _config;
  final GoogleSignIn _googleSignIn;
  final http.Client _http;
  final StreamController<FirebaseRestCredentials> _credentialsController =
      StreamController<FirebaseRestCredentials>.broadcast();
  bool _initialized = false;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;

  Stream<FirebaseRestCredentials> get credentials =>
      _credentialsController.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    await _googleSignIn.initialize(
      // Em Android/iOS o plugin lê o clientId do google-services.json /
      // GoogleService-Info.plist. Em web é obrigatório passar explicitamente.
      clientId: kIsWeb ? _config.googleClientId : null,
    );
    _subscription = _googleSignIn.authenticationEvents.listen(
      _onAuthenticationEvent,
      onError: (Object error, StackTrace _) {
        _credentialsController.addError(
          ApiException(failure: Failure.unexpected(message: error.toString())),
        );
      },
    );
    _initialized = true;

    // Em web restaura a sessão se já havia um login ativo (no-op em mobile).
    unawaited(_googleSignIn.attemptLightweightAuthentication());
  }

  /// Dispara o fluxo de sign-in. Em mobile abre o picker nativo; em web
  /// é no-op (o clique no botão renderizado pelo Google é quem inicia).
  Future<void> triggerSignIn() async {
    await initialize();
    if (kIsWeb) return;
    try {
      await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _credentialsController.addError(
          const ApiException(failure: Failure.signInCancelled()),
        );
      } else {
        _credentialsController.addError(
          ApiException(failure: Failure.unexpected(message: e.description)),
        );
      }
    } on Object catch (e) {
      _credentialsController.addError(
        ApiException(failure: Failure.network(message: e.toString())),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } on Object catch (_) {
      // Ignorado: signOut local não deve derrubar o fluxo.
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _credentialsController.close();
  }

  Future<void> _onAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      await _handleSignIn(event.user);
    }
    // SignOut events são tratados pelo repo/cubit — nada a fazer aqui.
  }

  Future<void> _handleSignIn(GoogleSignInAccount account) async {
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      _credentialsController.addError(
        const ApiException(
          failure: Failure.unexpected(
            message: 'Google não devolveu idToken — verifique o clientId',
          ),
        ),
      );
      return;
    }
    try {
      final creds = await _exchangeGoogleIdToken(
        idToken,
        fallbackEmail: account.email,
        fallbackName: account.displayName,
      );
      _credentialsController.add(creds);
    } on ApiException catch (e) {
      _credentialsController.addError(e);
    }
  }

  Future<FirebaseRestCredentials> _exchangeGoogleIdToken(
    String googleIdToken, {
    required String fallbackEmail,
    String? fallbackName,
  }) async {
    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=${_config.firebaseWebApiKey}',
    );
    http.Response response;
    try {
      response = await _http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'postBody': 'id_token=$googleIdToken&providerId=google.com',
          'requestUri': 'http://localhost',
          'returnIdpCredential': true,
          'returnSecureToken': true,
        }),
      );
    } on Object catch (e) {
      throw ApiException(failure: Failure.network(message: e.toString()));
    }

    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return FirebaseRestCredentials(
        uid: decoded['localId'] as String,
        email: decoded['email'] as String? ?? fallbackEmail,
        name: decoded['displayName'] as String? ?? fallbackName,
        idToken: decoded['idToken'] as String,
        refreshToken: decoded['refreshToken'] as String?,
      );
    }
    throw ApiException(
      failure: _mapFirebaseError(decoded),
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  Failure _mapFirebaseError(Object? decoded) {
    final message = decoded is Map<String, dynamic>
        ? ((decoded['error'] as Map<String, dynamic>?)?['message'] as String?)
        : null;
    return switch (message) {
      'USER_DISABLED' =>
        const Failure.unauthorized(message: 'Usuário desabilitado'),
      'INVALID_IDP_RESPONSE' =>
        const Failure.unauthorized(message: 'Resposta do Google inválida'),
      _ => Failure.unexpected(message: message ?? 'Erro de autenticação'),
    };
  }
}

class FirebaseRestCredentials {
  const FirebaseRestCredentials({
    required this.uid,
    required this.email,
    required this.idToken,
    this.name,
    this.refreshToken,
  });

  final String uid;
  final String email;
  final String? name;
  final String idToken;
  final String? refreshToken;
}
