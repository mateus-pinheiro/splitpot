import 'dart:async';

/// Sinaliza que a API rejeitou uma requisição com 401 (token expirado/inválido).
///
/// `ApiClient` notifica e `AuthCubit` escuta para encerrar a sessão, o que
/// dispara o redirect do GoRouter para `/login`.
class SessionExpiredNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}
