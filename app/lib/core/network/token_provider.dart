/// Fonte do ID token a ser enviado no `Authorization: Bearer ...`.
///
/// Implementação dev usa Firebase Identity Toolkit REST; a versão de prod
/// (futura) vem do SDK nativo (firebase_auth).
abstract class TokenProvider {
  /// Retorna o token atual (null se não autenticado).
  Future<String?> getIdToken();
}
