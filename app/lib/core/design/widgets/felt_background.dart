import 'package:flutter/material.dart';

import '../tokens.dart';

/// Fundo verde-feltro: gradiente radial do design system.
///
/// CSS de referência:
/// ```css
/// background: radial-gradient(ellipse at 50% 0%, #155a36 0%, #0f3a24 40%, #0a2518 100%);
/// ```
///
/// O overlay de ruído do design foi removido: desenhar uma grade de
/// pixels a cada repaint inviabilizava a perf no Flutter web. O gradiente
/// sozinho já entrega a leitura visual de feltro.
class FeltBackground extends StatelessWidget {
  const FeltBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return const _FeltGradient().wrap(child);
  }
}

class _FeltGradient {
  const _FeltGradient();

  Widget wrap(Widget child) {
    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -1.2),
                  radius: 1.3,
                  colors: [
                    SpColors.feltLight,
                    SpColors.felt,
                    SpColors.feltDeep,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
