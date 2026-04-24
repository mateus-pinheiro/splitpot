import '../errors/failure.dart';

/// Exceção que carrega o mapeamento HTTP → [Failure].
class ApiException implements Exception {
  const ApiException({required this.failure, this.statusCode, this.body});

  final Failure failure;
  final int? statusCode;
  final String? body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}

Failure failureFromStatus(int status, String? message) {
  final msg = (message == null || message.isEmpty) ? null : message;
  return switch (status) {
    400 => Failure.validation(message: msg ?? 'Requisição inválida'),
    401 => Failure.unauthorized(message: msg),
    403 => Failure.unauthorized(message: msg ?? 'Sem permissão'),
    404 => Failure.notFound(message: msg),
    >= 500 => Failure.unexpected(message: msg ?? 'Erro no servidor'),
    _ => Failure.unexpected(message: msg),
  };
}
