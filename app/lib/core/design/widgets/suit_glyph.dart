import 'package:flutter/material.dart';

import '../tokens.dart';

enum Suit { spade, heart, diamond, club }

extension SuitGlyphX on Suit {
  String get glyph => switch (this) {
        Suit.spade => '♠',
        Suit.heart => '♥',
        Suit.diamond => '♦',
        Suit.club => '♣',
      };
}

/// Naipe de baralho (♠ ♥ ♦ ♣).
///
/// Usa Unicode renderizado em Text — consistência cross-platform +
/// sem assets extras. Cor default segue a convenção de baralho
/// (ouros/copas vermelhos, espadas/paus pretos).
class SuitGlyph extends StatelessWidget {
  const SuitGlyph({
    required this.suit,
    this.size = 16,
    this.color,
    super.key,
  });

  final Suit suit;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ??
        (suit == Suit.heart || suit == Suit.diamond
            ? SpColors.danger
            : const Color(0xFF111111));
    return Text(
      suit.glyph,
      style: TextStyle(
        fontSize: size,
        color: resolved,
        height: 1.0,
        fontFamilyFallback: const ['Apple Color Emoji', 'Segoe UI Symbol'],
      ),
    );
  }
}
