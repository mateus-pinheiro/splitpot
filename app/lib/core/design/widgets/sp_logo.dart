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

class _LogoChipPainter extends CustomPainter {
  _LogoChipPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    // ficha outer
    canvas.drawCircle(center, r - 2, Paint()..color = color);
    canvas.drawCircle(
      center,
      r - 2,
      Paint()
        ..color = const Color(0x4D2A1D08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // wedges
    final wedgePaint = Paint()..color = const Color(0x802A1D08);
    for (final a in [0, 60, 120, 180, 240, 300]) {
      final rad = a * 3.141592653589793 / 180;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rad);
      canvas.drawRect(
        Rect.fromLTWH(
          -size.width * 0.035,
          -r + 2,
          size.width * 0.07,
          size.width * 0.14,
        ),
        wedgePaint,
      );
      canvas.restore();
    }
    // miolo verde
    canvas.drawCircle(
      center,
      size.width * 0.25,
      Paint()..color = SpColors.felt,
    );
    // cruz +
    final stroke = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round;
    final arm = size.width * 0.14;
    canvas.drawLine(
      center.translate(-arm, 0),
      center.translate(arm, 0),
      stroke,
    );
    canvas.drawLine(
      center.translate(0, -arm),
      center.translate(0, arm),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _LogoChipPainter o) => o.color != color;
}
