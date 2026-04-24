import 'package:flutter/material.dart';

import '../design/tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: SpColors.gold,
      onPrimary: const Color(0xFF2A1D08),
      secondary: SpColors.goldBright,
      onSecondary: const Color(0xFF2A1D08),
      surface: SpColors.feltDeep,
      onSurface: SpColors.cream,
      error: SpColors.danger,
      onError: SpColors.ivory,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SpColors.feltDeep,
      fontFamily: SpTypography.uiFamily,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: SpTypography.displayFamily,
          fontWeight: FontWeight.w700,
          color: SpColors.cream,
          letterSpacing: -0.02 * 56,
        ),
        displayMedium: TextStyle(
          fontFamily: SpTypography.displayFamily,
          fontWeight: FontWeight.w700,
          color: SpColors.cream,
          letterSpacing: -0.02 * 36,
        ),
        headlineSmall: TextStyle(
          fontFamily: SpTypography.displayFamily,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: SpColors.cream,
        ),
        titleLarge: TextStyle(
          fontFamily: SpTypography.displayFamily,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: SpColors.cream,
        ),
        bodyLarge: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 15,
          color: SpColors.cream,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 13,
          color: SpColors.cream,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: SpTypography.uiFamily,
          fontSize: 12,
          color: SpColors.muted,
          height: 1.4,
        ),
        labelSmall: SpTypography.goldEyebrow,
      ),
      iconTheme: const IconThemeData(color: SpColors.goldBright),
    );
  }
}
