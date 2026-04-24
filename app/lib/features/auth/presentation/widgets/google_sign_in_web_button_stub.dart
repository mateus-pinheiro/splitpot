import 'package:flutter/widgets.dart';

/// Stub para plataformas não-web. O conditional import em
/// [google_sign_in_web_button.dart] troca por uma versão que chama
/// `google_sign_in_web/web_only.dart`.
Widget buildGoogleSignInWebButton() => const SizedBox.shrink();
