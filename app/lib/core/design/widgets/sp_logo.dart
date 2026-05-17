import 'package:flutter/material.dart';

import '../tokens.dart';

/// Wordmark "Splitpot" com o chip-logo dourado à esquerda.
class SpLogo extends StatelessWidget {
  const SpLogo({
    this.size = 22,
    this.color = SpColors.goldBright,
    this.showTitle = true,
    super.key,
  });

  final double size;
  final Color color;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icon/app_icon.png',
          width: size * 1.3,
          height: size * 1.3,
        ),
        if (showTitle) ...[
          const SizedBox(width: 8),
          Text(
            'SplitPot',
            style: TextStyle(
              fontFamily: SpTypography.displayFamily,
              fontSize: size,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.22,
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}
