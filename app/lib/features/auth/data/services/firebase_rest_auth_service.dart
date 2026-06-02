import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_provider.dart';
import 'apple_sign_in_service.dart';
import 'firebase_identity_toolkit_api.dart';

/// Orquestra a obtenção de credenciais Firebase a partir dos 4 fluxos:
/// Google, Apple, email/senha (login) e email/senha (cadastro).
///
/// O contrato com o resto do app é o stream [credentials]: qualquer
/// caminho de sucesso (Google/Apple/password sign-in) emite uma
/// [FirebaseRestCredentials] aqui. O cadastro por senha é a única
/// exceção — devolve as credenciais direto via [signUpWithPassword]
/// porque o repositório precisa orquestrar `POST /users/me` antes do
/// stream resolver `signInOutcomes` (senão cairia em `needsProfile`
/// transitório).
class FirebaseRestAuthService {
  FirebaseRestAuthService({
    required AppConfig config,
    required FirebaseIdentityToolkitApi identityToolkit,
    required AppleSignInService appleSignIn,
    GoogleSignIn? googleSignIn,
  })  : _config = config,
        _identityToolkit = identityToolkit,
        _appleSignIn = appleSignIn,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final AppConfig _config;
  final FirebaseIdentityToolkitApi _identityToolkit;
  final AppleSignInService _appleSignIn;
  final GoogleSignIn _googleSignIn;
  final StreamController<FirebaseRestCredentials> _credentialsController =
      StreamController<FirebaseRestCredentials>.broadcast();
  bool _googleInitialized = false;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleSubscription;

  Stream<FirebaseRestCredentials> get credentials =>
      _credentialsController.stream;

  Future<void> initialize() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize(
      // Em Android/iOS o plugin lê o clientId do google-services.json /
      // GoogleService-Info.plist. Em web é obrigatório passar explicitamente.
      // serverClientId é necessário no mobile para o plugin retornar idToken.
      clientId: kIsWeb ? _config.googleClientId : null,
      serverClientId: kIsWeb ? null : _config.googleClientId,
    );
    _googleSubscription = _googleSignIn.authenticationEvents.listen(
      _onGoogleAuthenticationEvent,
      onError: (Object error, StackTrace _) {
        _credentialsController.addError(
          ApiException(failure: Failure.unexpected(message: error.toString())),
        );
      },
    );
    _googleInitialized = true;

    // Em web restaura a sessão se já havia um login ativo (no-op em mobile).
    unawaited(_googleSignIn.attemptLightweightAuthentication());
  }

  /// Dispara o fluxo de sign-in Google. Em mobile abre o picker; em web
  /// é no-op (o clique no botão renderizado pelo Google é quem inicia).
  Future<void> triggerGoogleSignIn() async {
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

  /// Dispara o diálogo nativo de Sign in with Apple, troca o identityToken
  /// pelo Firebase ID token via Identity Toolkit e empurra no stream.
  Future<void> triggerAppleSignIn() async {
    try {
      final apple = await _appleSignIn.signIn();
      final session = await _identityToolkit.signInWithIdp(
        idToken: apple.identityToken,
        provider: AuthProvider.apple,
        rawNonce: apple.rawNonce,
      );
      _credentialsController.add(
        FirebaseRestCredentials(
          uid: session.uid,
          email: session.email.isNotEmpty ? session.email : (apple.email ?? ''),
          name: session.displayName ?? apple.fullName,
          idToken: session.idToken,
          refreshToken: session.refreshToken,
          provider: AuthProvider.apple,
        ),
      );
    } on ApiException catch (e) {
      _credentialsController.addError(e);
    } on Object catch (e) {
      _credentialsController.addError(
        ApiException(failure: Failure.unexpected(message: e.toString())),
      );
    }
  }

  /// Login email/senha. Empurra a credencial no stream igual aos outros.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _identityToolkit.signInWithPassword(
        email: email,
        password: password,
      );
      _credentialsController.add(
        FirebaseRestCredentials(
          uid: session.uid,
          email: session.email,
          name: session.displayName,
          idToken: session.idToken,
          refreshToken: session.refreshToken,
          provider: AuthProvider.password,
        ),
      );
    } on ApiException catch (e) {
      _credentialsController.addError(e);
    } on Object catch (e) {
      _credentialsController.addError(
        ApiException(failure: Failure.unexpected(message: e.toString())),
      );
    }
  }

  /// Cadastro email/senha. **Retorna direto** — não passa pelo stream
  /// porque o repositório precisa chamar `POST /users/me` na sequência
  /// e só então emitir `AuthAuthenticated`. Se empurrássemos no stream,
  /// `signInOutcomes` faria `GET /users/me` (404) e cairia em
  /// `SignInNeedsProfile` transitório.
  Future<FirebaseRestCredentials> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    final session = await _identityToolkit.signUp(
      email: email,
      password: password,
    );
    return FirebaseRestCredentials(
      uid: session.uid,
      email: session.email.isNotEmpty ? session.email : email,
      name: session.displayName,
      idToken: session.idToken,
      refreshToken: session.refreshToken,
      provider: AuthProvider.password,
    );
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } on Object catch (_) {
      // Ignorado: signOut local não deve derrubar o fluxo.
    }
  }

  Future<void> dispose() async {
    await _googleSubscription?.cancel();
    await _credentialsController.close();
  }

  Future<void> _onGoogleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      await _handleGoogleSignIn(event.user);
    }
    // SignOut events são tratados pelo repo/cubit — nada a fazer aqui.
  }

  Future<void> _handleGoogleSignIn(GoogleSignInAccount account) async {
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
      final session = await _identityToolkit.signInWithIdp(
        idToken: idToken,
        provider: AuthProvider.google,
      );
      _credentialsController.add(
        FirebaseRestCredentials(
          uid: session.uid,
          email: session.email.isNotEmpty ? session.email : account.email,
          name: session.displayName ?? account.displayName,
          idToken: session.idToken,
          refreshToken: session.refreshToken,
          provider: AuthProvider.google,
        ),
      );
    } on ApiException catch (e) {
      _credentialsController.addError(e);
    }
  }
}

class FirebaseRestCredentials {
  const FirebaseRestCredentials({
    required this.uid,
    required this.email,
    required this.idToken,
    required this.provider,
    this.name,
    this.refreshToken,
  });

  final String uid;
  final String email;
  final String? name;
  final String idToken;
  final String? refreshToken;
  final AuthProvider provider;
}
