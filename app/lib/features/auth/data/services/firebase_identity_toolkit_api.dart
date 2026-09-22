import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/auth_provider.dart';

/// Cliente HTTP puro pra Firebase Identity Toolkit. Centraliza o
/// `firebaseWebApiKey`, parsing das respostas e mapeamento de erros
/// Firebase → [Failure]. Os outros serviços (Google, Apple, password)
/// delegam pra cá ao invés de cada um falar com `identitytoolkit`.
class FirebaseIdentityToolkitApi {
  FirebaseIdentityToolkitApi({
    required AppConfig config,
    http.Client? httpClient,
  })  : _config = config,
        _http = httpClient ?? http.Client();

  final AppConfig _config;
  final http.Client _http;

  /// Troca um idToken de provider (Google/Apple) por credenciais Firebase.
  Future<IdentityToolkitSession> signInWithIdp({
    required String idToken,
    required AuthProvider provider,
    String? rawNonce,
  }) async {
    final body = StringBuffer('id_token=$idToken&providerId=${provider.firebaseProviderId}');
    if (rawNonce != null) {
      body.write('&nonce=$rawNonce');
    }
    final decoded = await _post('accounts:signInWithIdp', {
      'postBody': body.toString(),
      'requestUri': 'http://localhost',
      'returnIdpCredential': true,
      'returnSecureToken': true,
    });
    return IdentityToolkitSession.fromJson(decoded);
  }

  /// Login email/senha.
  Future<IdentityToolkitSession> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final decoded = await _post('accounts:signInWithPassword', {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });
    return IdentityToolkitSession.fromJson(decoded);
  }

  /// Cadastro email/senha.
  Future<IdentityToolkitSession> signUp({
    required String email,
    required String password,
  }) async {
    final decoded = await _post('accounts:signUp', {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });
    return IdentityToolkitSession.fromJson(decoded);
  }

  /// Troca o refresh token por um ID token novo. Roda em outro host
  /// (`securetoken`) e é o único jeito de manter a sessão viva além da hora
  /// de validade fixa do ID token.
  Future<RefreshedTokens> refreshIdToken(String refreshToken) async {
    final decoded = await _postTo(
      Uri.parse(
        'https://securetoken.googleapis.com/v1/token?key=${_config.firebaseWebApiKey}',
      ),
      {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
    );
    return RefreshedTokens.fromJson(decoded);
  }

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> payload,
  ) {
    return _postTo(
      Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/$endpoint?key=${_config.firebaseWebApiKey}',
      ),
      payload,
    );
  }

  Future<Map<String, dynamic>> _postTo(
    Uri uri,
    Map<String, dynamic> payload,
  ) async {
    http.Response response;
    try {
      response = await _http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } on Object catch (e) {
      throw ApiException(failure: Failure.network(message: e.toString()));
    }

    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw ApiException(
      failure: _mapError(decoded),
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  Failure _mapError(Object? decoded) {
    final raw = decoded is Map<String, dynamic>
        ? ((decoded['error'] as Map<String, dynamic>?)?['message'] as String?)
        : null;
    // Firebase às vezes anexa contexto separado por " : " (ex: "WEAK_PASSWORD : Password should be at least 6 characters").
    final code = raw?.split(' : ').first.trim();
    return switch (code) {
      'EMAIL_NOT_FOUND' ||
      'INVALID_PASSWORD' ||
      'INVALID_LOGIN_CREDENTIALS' =>
        const Failure.unauthorized(message: 'Email ou senha incorretos.'),
      'USER_DISABLED' => const Failure.unauthorized(
        message: 'Conta desabilitada. Contate o suporte.',
      ),
      'EMAIL_EXISTS' => const Failure.validation(
        message:
            'Esse email já está cadastrado. Use Google/Apple ou recupere a senha.',
      ),
      'WEAK_PASSWORD' => const Failure.validation(
        message: 'Senha muito fraca. Use ao menos 6 caracteres.',
      ),
      'INVALID_EMAIL' => const Failure.validation(
        message: 'Email inválido.',
      ),
      'OPERATION_NOT_ALLOWED' => const Failure.unexpected(
        message:
            'Esse método de login não está habilitado. Avise o suporte.',
      ),
      'TOO_MANY_ATTEMPTS_TRY_LATER' => const Failure.unauthorized(
        message: 'Muitas tentativas. Tente novamente em alguns minutos.',
      ),
      'INVALID_IDP_RESPONSE' => const Failure.unauthorized(
        message: 'Resposta do provedor inválida. Tente novamente.',
      ),
      // Refresh token revogado/expirado — sessão morreu, precisa logar de novo.
      'TOKEN_EXPIRED' ||
      'INVALID_REFRESH_TOKEN' ||
      'USER_NOT_FOUND' =>
        const Failure.unauthorized(message: 'Sessão expirada. Entre de novo.'),
      _ => Failure.unexpected(message: raw ?? 'Erro de autenticação.'),
    };
  }
}

/// Resultado bruto de qualquer endpoint do Identity Toolkit que devolve
/// sessão (idToken + refreshToken + dados do usuário).
class IdentityToolkitSession {
  const IdentityToolkitSession({
    required this.uid,
    required this.email,
    required this.idToken,
    required this.expiresIn,
    this.displayName,
    this.refreshToken,
  });

  factory IdentityToolkitSession.fromJson(Map<String, dynamic> json) {
    return IdentityToolkitSession(
      uid: json['localId'] as String,
      email: (json['email'] as String?) ?? '',
      displayName: json['displayName'] as String?,
      idToken: json['idToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: parseExpiresIn(json['expiresIn']),
    );
  }

  final String uid;
  final String email;
  final String? displayName;
  final String idToken;
  final String? refreshToken;

  /// Validade do ID token. O Firebase sempre devolve 3600s e o valor não é
  /// configurável — por isso a sessão longa depende do refresh token, não
  /// de esticar esse prazo.
  final Duration expiresIn;
}

/// Firebase manda `expiresIn`/`expires_in` como string de segundos.
Duration parseExpiresIn(Object? raw) {
  final seconds = switch (raw) {
    final int v => v,
    final String v => int.tryParse(v) ?? 3600,
    _ => 3600,
  };
  return Duration(seconds: seconds);
}

/// Par de tokens devolvido pelo endpoint de refresh (securetoken).
class RefreshedTokens {
  const RefreshedTokens({
    required this.idToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory RefreshedTokens.fromJson(Map<String, dynamic> json) {
    return RefreshedTokens(
      idToken: json['id_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: parseExpiresIn(json['expires_in']),
    );
  }

  final String idToken;
  final String refreshToken;
  final Duration expiresIn;
}
