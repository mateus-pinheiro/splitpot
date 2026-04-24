import '../../../../core/network/token_provider.dart';

/// Guarda o ID token atual em memória e serve como [TokenProvider] pra
/// o [ApiClient]. Em prod pode ser trocado por algo persistente
/// (secure storage) sem mexer em camadas acima.
class FirebaseTokenStore implements TokenProvider {
  String? _idToken;

  void set(String? idToken) {
    _idToken = idToken;
  }

  void clear() {
    _idToken = null;
  }

  @override
  Future<String?> getIdToken() async => _idToken;
}
