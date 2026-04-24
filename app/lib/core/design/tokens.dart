import 'package:flutter/material.dart';

/// Tokens do design system Splitpot. Valores espelhados 1:1 de `styles.css`
/// do handoff — não alterar sem atualizar a referência.
class SpColors {
  const SpColors._();

  static const feltDeep = Color(0xFF0A2518);
  static const felt = Color(0xFF0F3A24);
  static const feltLight = Color(0xFF155A36);
  static const feltRail = Color(0xFF08190F);

  static const gold = Color(0xFFD4A24A);
  static const goldBright = Color(0xFFF0C770);
  static const goldDark = Color(0xFF8E6A26);

  static const cream = Color(0xFFF5ECD6);
  static const ivory = Color(0xFFFBF6E8);
  static const bone = Color(0xFFE8DCBF);

  static const ink = Color(0xFF0C1A12);
  static const muted = Color(0xFF8FA79A);

  static const danger = Color(0xFFC0392B);
  static const dangerSoft = Color(0xFFE57373);
  static const success = Color(0xFF2E8F5A);
  static const successSoft = Color(0xFF6BC997);

  /// Gradiente signature de "ouro cravado". Usar com [ShaderMask] em
  /// `Text` (brand wordmark, totais grandes).
  static const goldFoilGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF3D27B),
      Color(0xFFD4A24A),
      Color(0xFFA5791F),
      Color(0xFFE8BD60),
    ],
    stops: [0.0, 0.45, 0.55, 1.0],
  );

  /// Gradiente vertical do botão ouro (CTA principal).
  static const goldButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0C770), Color(0xFFD4A24A), Color(0xFFB5832E)],
    stops: [0.0, 0.5, 1.0],
  );
}

class SpSpacing {
  const SpSpacing._();
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const huge = 40.0;

  /// Padding horizontal padrão de tela.
  static const screenHorizontal = 20.0;
}

class SpRadius {
  const SpRadius._();
  static const tag = 8.0;
  static const input = 10.0;
  static const listItem = 12.0;
  static const card = 14.0;
  static const hero = 16.0;
  static const qr = 20.0;
}

class SpTypography {
  const SpTypography._();

  static const displayFamily = 'Rubik';
  static const uiFamily = 'Rubik';
  static const numFamily = 'JetBrainsMono';

  /// Micro-label dourado (uppercase, 0.1em tracking). Signature do DS.
  static const TextStyle goldEyebrow = TextStyle(
    fontFamily: uiFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: SpColors.gold,
    letterSpacing: 1.1,
  );

  static const TextStyle goldEyebrowLarge = TextStyle(
    fontFamily: uiFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: SpColors.gold,
    letterSpacing: 1.65,
  );
}
