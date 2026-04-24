import 'package:flutter/material.dart';

import '../tokens.dart';

/// Divider com gradient dourado nas pontas (fade → ouro → fade).
class GoldDivider extends StatelessWidget {
  const GoldDivider({this.height = 1, super.key});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            SpColors.gold.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
