import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../errors/failure.dart';
import 'api_exception.dart';
import 'token_provider.dart';

/// Cliente HTTP mínimo para a API do SplitPot.
///
/// Injeta `Authorization: Bearer <idToken>` quando disponível e converte
/// erros em [ApiException] com o [Failure] correspondente — presentation
/// só lida com `Failure`.
class ApiClient {
  ApiClient({
    required AppConfig config,
    required TokenProvider tokenProvider,
    http.Client? httpClient,
  })  : _config = config,
        _tokenProvider = tokenProvider,
        _http = httpClient ?? http.Client();

  final AppConfig _config;
  final TokenProvider _tokenProvider;
  final http.Client _http;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _send('GET', path, query: query);
    return _decodeObject(response);
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _send('GET', path, query: query);
    return _decodeList(response);
  }

  Future<Map<String, dynamic>?> getOrNull(
    String path, {
    Map<String, String>? query,
  }) async {
    try {
      return await get(path, query: query);
    } on ApiException catch (e) {
      if (e.failure is NotFoundFailure) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
  }) async {
    final response = await _send('POST', path, body: body);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
  }) async {
    final response = await _send('PATCH', path, body: body);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
  }) async {
    final response = await _send('PUT', path, body: body);
    return _decodeObject(response);
  }

  Future<void> delete(String path) async {
    await _send('DELETE', path);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _buildUri(path, query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };
    final token = await _tokenProvider.getIdToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    http.StreamedResponse streamed;
    try {
      streamed = await _http.send(request);
    } on Object catch (e) {
      throw ApiException(
        failure: Failure.network(message: e.toString()),
      );
    }
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    throw _mapError(response);
  }

  Uri _buildUri(String path, Map<String, String>? query) {
    final base = Uri.parse(_config.apiBaseUrl);
    final joinedPath = path.startsWith('/')
        ? '${base.path}$path'
        : '${base.path}/$path';
    return base.replace(
      path: joinedPath,
      queryParameters: query?.isNotEmpty ?? false ? query : null,
    );
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    if (response.body.isEmpty) return const <String, dynamic>{};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException(
      failure: const Failure.unexpected(message: 'Resposta não é um objeto'),
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  List<dynamic> _decodeList(http.Response response) {
    if (response.body.isEmpty) return const <dynamic>[];
    final decoded = jsonDecode(response.body);
    if (decoded is List) return decoded;
    throw ApiException(
      failure: const Failure.unexpected(message: 'Resposta não é uma lista'),
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  ApiException _mapError(http.Response response) {
    String? message;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] is String) {
        message = decoded['message'] as String;
      } else if (decoded is Map && decoded['message'] is List) {
        message = (decoded['message'] as List).join('; ');
      }
    } on Object catch (_) {
      message = response.body;
    }
    return ApiException(
      failure: failureFromStatus(response.statusCode, message),
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}
