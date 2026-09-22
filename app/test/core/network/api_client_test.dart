import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:splitpot/core/config/app_config.dart';
import 'package:splitpot/core/network/api_client.dart';
import 'package:splitpot/core/network/token_provider.dart';

class _NoToken implements TokenProvider {
  @override
  Future<String?> getIdToken() async => null;
}

/// Captura a URL de cada request e devolve `{}`.
class _Recorder {
  final List<Uri> urls = [];

  http.Client client() => MockClient((request) async {
        urls.add(request.url);
        return http.Response('{}', 200);
      });
}

void main() {
  late _Recorder recorder;
  late ApiClient api;

  setUp(() {
    recorder = _Recorder();
    api = ApiClient(
      config: const AppConfig(
        apiBaseUrl: 'https://example.test/api',
        webBaseUrl: 'https://example.test/app',
        firebaseWebApiKey: 'test-key',
        googleClientId: 'test-client-id',
      ),
      tokenProvider: _NoToken(),
      httpClient: recorder.client(),
    );
  });

  test('monta path simples sob o base path', () async {
    await api.put('/participations/p1/cash-out', body: {'amount': 10});

    expect(recorder.urls.single.path, '/api/participations/p1/cash-out');
    expect(recorder.urls.single.queryParameters, isEmpty);
  });

  test('envia query sem misturar com o path', () async {
    await api.put(
      '/participations/p1/cash-out',
      body: {'amount': 10},
      query: const {'skipAutoClose': 'true'},
    );

    expect(recorder.urls.single.path, '/api/participations/p1/cash-out');
    expect(recorder.urls.single.queryParameters, {'skipAutoClose': 'true'});
  });

  test('separa query embutida no path em vez de encodar o "?"', () async {
    // Regressão: `Uri.replace(path:)` transformava o `?` em `%3F`, a rota
    // não casava no servidor e a tela de conferência falhava com 404 ao
    // salvar os ajustes — a mesa nunca fechava por ali.
    await api.put('/participations/p1/cash-out?skipAutoClose=true');

    expect(recorder.urls.single.path, '/api/participations/p1/cash-out');
    expect(recorder.urls.single.queryParameters, {'skipAutoClose': 'true'});
    expect(recorder.urls.single.toString(), isNot(contains('%3F')));
  });
}
