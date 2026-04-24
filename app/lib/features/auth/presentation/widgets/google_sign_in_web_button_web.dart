import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

/// Renderiza o botão do Google Identity Services. Necessário em web
/// porque `GoogleSignIn.instance.authenticate()` não está implementado
/// — quem dispara o popup é o clique no botão renderizado pelo GIS.
Widget buildGoogleSignInWebButton() => web.renderButton();
