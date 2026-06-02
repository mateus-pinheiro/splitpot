import '../entities/email_providers_lookup.dart';
import '../repositories/auth_repository.dart';

/// Descobre se o email já está cadastrado e quais providers (Google/
/// Apple/password) estão vinculados. Usado pra rotear o usuário direto
/// pro provider correto quando ele digita um email já registrado.
class LookupEmailProviders {
  const LookupEmailProviders(this._repository);

  final AuthRepository _repository;

  Future<EmailProvidersLookup> call(String email) {
    return _repository.lookupEmailProviders(email);
  }
}
