import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';

/// Wrapper fino sobre `sign_in_with_apple`.
///
/// Disponível apenas em iOS native — a UI gate o botão com
/// `defaultTargetPlatform == TargetPlatform.iOS`. Aqui não validamos a
/// plataforma: a chamada vai falhar com [Failure.unexpected] se rolar
/// em algum outro lugar, o que é o comportamento desejado.
///
/// Nonce: Firebase exige o **raw** nonce no body do `signInWithIdp` e
/// o **sha256(raw)** no `getAppleIDCredential.nonce`. Trocar esses dois
/// quebra a verificação Apple → Firebase, e é o erro mais comum.
class AppleSignInService {
  AppleSignInService({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  Future<AppleSignInResult> signIn() async {
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const ApiException(
          failure: Failure.unexpected(
            message: 'Apple não devolveu identityToken.',
          ),
        );
      }
      return AppleSignInResult(
        identityToken: idToken,
        rawNonce: rawNonce,
        fullName: _composeFullName(credential.givenName, credential.familyName),
        email: credential.email,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const ApiException(failure: Failure.signInCancelled());
      }
      throw ApiException(
        failure: Failure.unexpected(message: e.message),
      );
    } on ApiException {
      rethrow;
    } on Object catch (e) {
      throw ApiException(failure: Failure.unexpected(message: e.toString()));
    }
  }

  String _generateNonce({int length = 32}) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._';
    return List.generate(
      length,
      (_) => charset[_random.nextInt(charset.length)],
    ).join();
  }

  String? _composeFullName(String? given, String? family) {
    final parts = [given, family].whereType<String>().where((p) => p.isNotEmpty);
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }
}

class AppleSignInResult {
  const AppleSignInResult({
    required this.identityToken,
    required this.rawNonce,
    this.fullName,
    this.email,
  });

  final String identityToken;
  final String rawNonce;

  /// Apple só devolve nome **no primeiro login**. Logins seguintes vêm
  /// vazios — por isso é importante persistir já na primeira passagem.
  final String? fullName;
  final String? email;
}
