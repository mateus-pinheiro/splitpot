import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Sessão persistida entre aberturas do app.
///
/// O `idToken` é guardado só pra evitar um refresh desnecessário quando o
/// app reabre dentro da hora de validade. Quem realmente sustenta a sessão
/// longa é o `refreshToken`.
class StoredSession {
  const StoredSession({
    required this.idToken,
    required this.refreshToken,
    required this.idTokenExpiresAt,
    required this.startedAt,
  });

  factory StoredSession.fromJson(Map<String, dynamic> json) {
    return StoredSession(
      idToken: json['idToken'] as String,
      refreshToken: json['refreshToken'] as String,
      idTokenExpiresAt:
          DateTime.parse(json['idTokenExpiresAt'] as String).toUtc(),
      startedAt: DateTime.parse(json['startedAt'] as String).toUtc(),
    );
  }

  final String idToken;
  final String refreshToken;
  final DateTime idTokenExpiresAt;

  /// Quando o usuário fez login de verdade. É daqui que sai o corte de 30
  /// dias — renovar o ID token não estende esse prazo.
  final DateTime startedAt;

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
        'refreshToken': refreshToken,
        'idTokenExpiresAt': idTokenExpiresAt.toUtc().toIso8601String(),
        'startedAt': startedAt.toUtc().toIso8601String(),
      };

  StoredSession copyWith({
    String? idToken,
    String? refreshToken,
    DateTime? idTokenExpiresAt,
  }) {
    return StoredSession(
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken ?? this.refreshToken,
      idTokenExpiresAt: idTokenExpiresAt ?? this.idTokenExpiresAt,
      startedAt: startedAt,
    );
  }
}

abstract class SessionStorage {
  Future<StoredSession?> read();
  Future<void> write(StoredSession session);
  Future<void> clear();
}

/// Persiste em `SharedPreferences` (localStorage na web, NSUserDefaults no
/// iOS, SharedPreferences no Android) como um único JSON.
class SharedPrefsSessionStorage implements SessionStorage {
  SharedPrefsSessionStorage({SharedPreferences? prefs}) : _prefs = prefs;

  static const _key = 'splitpot.session';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<StoredSession?> read() async {
    final prefs = await _instance;
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return StoredSession.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object catch (_) {
      // Formato antigo/corrompido: descarta em vez de travar o boot.
      await prefs.remove(_key);
      return null;
    }
  }

  @override
  Future<void> write(StoredSession session) async {
    final prefs = await _instance;
    await prefs.setString(_key, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() async {
    final prefs = await _instance;
    await prefs.remove(_key);
  }
}
