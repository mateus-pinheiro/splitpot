import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Pilha de fichas de poker desenhada em [CustomPainter]. Cada ficha é
/// um círculo colorido com 8 wedges brancos na borda, miolo creme com
/// anéis dourados. `count` empilha com offset vertical de 3px/ficha
/// (tilt opcional pra decoração diagonal).
class PokerChipStack extends StatelessWidget {
  const PokerChipStack({
    this.size = 36,
    this.color = SpColors.danger,
    this.count = 1,
    this.tilt = false,
    super.key,
  });

  final double size;
  final Color color;
  final int count;
  final bool tilt;

  @override
  Widget build(BuildContext context) {
    final stackHeight = size * 0.9 + (count - 1) * 3;
    Widget stack = SizedBox(
      width: size,
      height: stackHeight,
      child: CustomPaint(
        painter: _ChipStackPainter(color: color, count: count, chipSize: size),
      ),
    );
    if (tilt) {
      stack = Transform.rotate(angle: -8 * math.pi / 180, child: stack);
    }
    return stack;
  }
}

class _ChipStackPainter extends CustomPainter {
  _ChipStackPainter({
    required this.color,
    required this.count,
    required this.chipSize,
  });

  final Color color;
  final int count;
  final double chipSize;

  static const _face = SpColors.cream;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < count; i++) {
      // Pilha cresce pra cima: ficha mais de baixo pinta primeiro (y maior).
      final offsetY = (count - 1 - i) * 3.0;
      _drawChip(canvas, offsetY);
    }
  }

  void _drawChip(Canvas canvas, double offsetY) {
    final cx = chipSize / 2;
    final cy = offsetY + chipSize / 2;
    final r = chipSize / 2 - 1;

    // Corpo
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = color);
    // Borda sombreada
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Wedges (8 retângulos nos ângulos 0,45,90...)
    final wedgeW = chipSize * 0.05;
    final wedgeH = chipSize * 0.15;
    final wedgePaint = Paint()..color = _face;
    for (final angleDeg in const [0, 45, 90, 135, 180, 225, 270, 315]) {
      final a = angleDeg * math.pi / 180;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(a);
      canvas.drawRect(
        Rect.fromLTWH(-wedgeW / 2, -r, wedgeW, wedgeH),
        wedgePaint,
      );
      canvas.restore();
    }

    // Miolo creme
    final faceR = chipSize * 0.325;
    canvas.drawCircle(Offset(cx, cy), faceR, Paint()..color = _face);

    // Anel dourado interno + anel fino
    canvas.drawCircle(
      Offset(cx, cy),
      chipSize * 0.225,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      faceR,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant _ChipStackPainter o) =>
      o.color != color || o.count != count || o.chipSize != chipSize;
}
