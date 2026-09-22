import 'dart:async';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/token_provider.dart';
import 'firebase_identity_toolkit_api.dart';
import 'session_storage.dart';

/// Guarda a sessão Firebase e serve o ID token pro [ApiClient].
///
/// O ID token do Firebase vale 1 hora e esse prazo **não é configurável**.
/// Sessão longa, então, é responsabilidade daqui: o refresh token fica
/// persistido e é trocado por um ID token novo sempre que o atual está
/// perto de vencer. O corte de [maxSessionAge] é contado a partir do login
/// de verdade — renovar o ID token não estende esse prazo.
class FirebaseTokenStore implements TokenProvider {
  FirebaseTokenStore({
    required SessionStorage storage,
    required FirebaseIdentityToolkitApi identityToolkit,
    this.maxSessionAge = const Duration(days: 30),
    this.refreshSkew = const Duration(minutes: 2),
    DateTime Function()? clock,
  })  : _storage = storage,
        _identityToolkit = identityToolkit,
        _now = clock ?? DateTime.now;

  final SessionStorage _storage;
  final FirebaseIdentityToolkitApi _identityToolkit;
  final DateTime Function() _now;

  /// Quanto tempo a sessão sobrevive sem um novo login.
  final Duration maxSessionAge;

  /// Margem pra renovar antes de o ID token vencer de fato, evitando 401 em
  /// requisição que sai no limite.
  final Duration refreshSkew;

  StoredSession? _session;

  /// Garante um único refresh em voo: várias chamadas concorrentes ao
  /// `getIdToken` compartilham a mesma troca em vez de queimar o refresh
  /// token várias vezes.
  Future<String?>? _inFlightRefresh;

  /// Lê a sessão do disco. Chamado no bootstrap, antes do primeiro request.
  Future<void> restore() async {
    _session = await _storage.read();
    if (_session != null && _isBeyondMaxAge(_session!)) {
      await clear();
    }
  }

  /// Persiste a sessão recém-criada por um login. Reinicia a janela de
  /// [maxSessionAge].
  Future<void> save({
    required String idToken,
    required String? refreshToken,
    required Duration expiresIn,
  }) async {
    if (refreshToken == null) {
      // Sem refresh token não há sessão longa possível: mantém só em
      // memória e deixa o 401 encerrar quando o ID token vencer.
      _session = null;
      _memoryOnlyIdToken = idToken;
      await _storage.clear();
      return;
    }
    _memoryOnlyIdToken = null;
    final session = StoredSession(
      idToken: idToken,
      refreshToken: refreshToken,
      idTokenExpiresAt: _now().toUtc().add(expiresIn),
      startedAt: _now().toUtc(),
    );
    _session = session;
    await _storage.write(session);
  }

  Future<void> clear() async {
    _session = null;
    _memoryOnlyIdToken = null;
    _inFlightRefresh = null;
    await _storage.clear();
  }

  String? _memoryOnlyIdToken;

  @override
  Future<String?> getIdToken() async {
    final session = _session;
    if (session == null) return _memoryOnlyIdToken;

    if (_isBeyondMaxAge(session)) {
      await clear();
      return null;
    }
    if (_now().toUtc().isBefore(
          session.idTokenExpiresAt.subtract(refreshSkew),
        )) {
      return session.idToken;
    }
    return _inFlightRefresh ??= _refresh(session).whenComplete(() {
      _inFlightRefresh = null;
    });
  }

  Future<String?> _refresh(StoredSession session) async {
    try {
      final tokens = await _identityToolkit.refreshIdToken(
        session.refreshToken,
      );
      final next = session.copyWith(
        idToken: tokens.idToken,
        refreshToken: tokens.refreshToken,
        idTokenExpiresAt: _now().toUtc().add(tokens.expiresIn),
      );
      _session = next;
      await _storage.write(next);
      return next.idToken;
    } on ApiException catch (_) {
      // Refresh token revogado, expirado ou usuário removido: a sessão
      // acabou. Devolver null faz a request sair sem Authorization e o 401
      // do backend leva o AuthCubit pro login.
      await clear();
      return null;
    }
  }

  bool _isBeyondMaxAge(StoredSession session) =>
      _now().toUtc().difference(session.startedAt) >= maxSessionAge;
}
