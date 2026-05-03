import 'package:flutter/material.dart';

import '../tokens.dart';

/// Spinning chip icon — reusable loading indicator for the Splitpot brand.
///
/// Use [SpLoader] as an inline spinner, or [SpLoadingScreen] for a full-screen
/// felt-background overlay.
class SpLoader extends StatefulWidget {
  const SpLoader({this.size = 48, super.key});

  /// Diameter of the spinning chip icon.
  final double size;

  @override
  State<SpLoader> createState() => _SpLoaderState();
}

class _SpLoaderState extends State<SpLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _ctrl,
          child: Image.asset(
            'assets/icon/app_icon.png',
            width: widget.size,
            height: widget.size,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Full-screen felt-background overlay with the [SpLoader] centered.
///
/// Wraps [child] in a [Stack] and places the loading overlay on top
/// whenever [loading] is `true`. The overlay fades in/out smoothly.
class SpLoadingScreen extends StatelessWidget {
  const SpLoadingScreen({
    required this.loading,
    required this.child,
    this.loaderSize = 56,
    super.key,
  });

  final bool loading;
  final Widget child;
  final double loaderSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        AnimatedOpacity(
          opacity: loading ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeIn,
          child: IgnorePointer(
            ignoring: !loading,
            child: DecoratedBox(
              decoration: const BoxDecoration(
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
              child: SizedBox.expand(
                child: Center(
                  child: SpLoader(size: loaderSize),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
