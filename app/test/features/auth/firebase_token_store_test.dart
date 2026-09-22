import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:splitpot/core/config/app_config.dart';
import 'package:splitpot/features/auth/data/services/firebase_identity_toolkit_api.dart';
import 'package:splitpot/features/auth/data/services/firebase_token_store.dart';
import 'package:splitpot/features/auth/data/services/session_storage.dart';

class _MemoryStorage implements SessionStorage {
  StoredSession? session;

  @override
  Future<StoredSession?> read() async => session;

  @override
  Future<void> write(StoredSession s) async => session = s;

  @override
  Future<void> clear() async => session = null;
}

const _config = AppConfig(
  apiBaseUrl: 'https://example.test/api',
  webBaseUrl: 'https://example.test/app',
  firebaseWebApiKey: 'test-key',
  googleClientId: 'test-client-id',
);

/// Identity Toolkit falso: conta os refreshes e devolve tokens novos.
class _FakeToolkit {
  int calls = 0;
  bool fail = false;
  final List<String> sentRefreshTokens = [];

  FirebaseIdentityToolkitApi build() {
    return FirebaseIdentityToolkitApi(
      config: _config,
      httpClient: MockClient((request) async {
        calls += 1;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        sentRefreshTokens.add(body['refresh_token'] as String);
        if (fail) {
          return http.Response(
            jsonEncode({
              'error': {'message': 'TOKEN_EXPIRED'},
            }),
            400,
          );
        }
        return http.Response(
          jsonEncode({
            'id_token': 'novo-id-token-$calls',
            'refresh_token': 'novo-refresh-$calls',
            'expires_in': '3600',
          }),
          200,
        );
      }),
    );
  }
}

void main() {
  late _MemoryStorage storage;
  late _FakeToolkit toolkit;
  late DateTime now;

  FirebaseTokenStore build() => FirebaseTokenStore(
        storage: storage,
        identityToolkit: toolkit.build(),
        clock: () => now,
      );

  setUp(() {
    storage = _MemoryStorage();
    toolkit = _FakeToolkit();
    now = DateTime.utc(2026, 9, 22, 12);
  });

  test('persiste a sessão no login e devolve o token sem refresh', () async {
    final store = build();

    await store.save(
      idToken: 'id-token',
      refreshToken: 'refresh-token',
      expiresIn: const Duration(hours: 1),
    );

    expect(await store.getIdToken(), 'id-token');
    expect(toolkit.calls, 0);
    expect(storage.session?.refreshToken, 'refresh-token');
  });

  test('restaura a sessão depois de reabrir o app', () async {
    await build().save(
      idToken: 'id-token',
      refreshToken: 'refresh-token',
      expiresIn: const Duration(hours: 1),
    );

    // Instância nova, como se o app tivesse sido reaberto.
    final reopened = build();
    await reopened.restore();

    expect(await reopened.getIdToken(), 'id-token');
  });

  test('renova o ID token quando ele está perto de vencer', () async {
    final store = build();
    await store.save(
      idToken: 'id-token',
      refreshToken: 'refresh-token',
      expiresIn: const Duration(hours: 1),
    );

    now = now.add(const Duration(minutes: 59, seconds: 30));

    expect(await store.getIdToken(), 'novo-id-token-1');
    expect(toolkit.calls, 1);
    expect(toolkit.sentRefreshTokens, ['refresh-token']);
    // O refresh token rotacionado também é persistido.
    expect(storage.session?.refreshToken, 'novo-refresh-1');
  });

  test('chamadas concorrentes compartilham um único refresh', () async {
    final store = build();
    await store.save(
      idToken: 'id-token',
      refreshToken: 'refresh-token',
      expiresIn: const Duration(hours: 1),
    );
    now = now.add(const Duration(hours: 2));

    final tokens = await Future.wait([
      store.getIdToken(),
      store.getIdToken(),
      store.getIdToken(),
    ]);

    expect(tokens, ['novo-id-token-1', 'novo-id-token-1', 'novo-id-token-1']);
    expect(toolkit.calls, 1);
  });

  test('mantém a sessão viva por 29 dias', () async {
    final store = build();
    await store.save(
      idToken: 'id-token',
      refreshToken: 'refresh-token',
      expiresIn: const Duration(hours: 1),
    );

    now = now.add(const Duration(days: 29));

    expect(await store.getIdToken(), 'novo-id-token-1');
    expect(storage.session, isNotNull);
  });

  test('derruba a sessão no corte de 30 dias, mesmo com refresh válido',
      () async {
    final store = build();
    await store.save(
      idToken: 'id-token',
      refreshToken: 'refresh-token',
      expiresIn: const Duration(hours: 1),
    );

    now = now.add(const Duration(days: 30));

    expect(await store.getIdToken(), isNull);
    expect(toolkit.calls, 0);
    expect(storage.session, isNull);
  });

  test('limpa a sessão quando o refresh token é rejeitado', () async {
    final store = build();
    await store.save(
      idToken: 'id-token',
      refreshToken: 'refresh-token',
      expiresIn: const Duration(hours: 1),
    );
    toolkit.fail = true;
    now = now.add(const Duration(hours: 2));

    expect(await store.getIdToken(), isNull);
    expect(storage.session, isNull);
  });

  test('descarta a sessão expirada já no restore', () async {
    await build().save(
      idToken: 'id-token',
      refreshToken: 'refresh-token',
      expiresIn: const Duration(hours: 1),
    );

    now = now.add(const Duration(days: 31));
    final reopened = build();
    await reopened.restore();

    expect(storage.session, isNull);
    expect(await reopened.getIdToken(), isNull);
  });

  test('signOut limpa o que estava persistido', () async {
    final store = build();
    await store.save(
      idToken: 'id-token',
      refreshToken: 'refresh-token',
      expiresIn: const Duration(hours: 1),
    );

    await store.clear();

    expect(storage.session, isNull);
    expect(await store.getIdToken(), isNull);
  });
}
