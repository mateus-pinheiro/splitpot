import 'package:flutter/material.dart';

import '../tokens.dart';

/// Texto com efeito "gold foil" (gradiente dourado + sombra sutil).
/// Usado na wordmark "Splitpot" e em totais heróis (pote, P&L acumulado).
class GoldFoilText extends StatelessWidget {
  const GoldFoilText(
    this.text, {
    required this.style,
    this.textAlign,
    super.key,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => SpColors.goldFoilGradient.createShader(rect),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(
          color: Colors.white,
          shadows: const [
            Shadow(color: Color(0x26000000), offset: Offset(0, 1)),
          ],
        ),
      ),
    );
  }
}
