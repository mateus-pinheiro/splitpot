import 'package:flutter/material.dart';

import '../../../../core/design/tokens.dart';
import '../../../../core/design/widgets/sp_logo.dart';

/// Full-screen splash overlay shown on first app load.
///
/// Plays a two-phase animation:
///   1. Logo fades + scales in.
///   2. When [onDismiss] triggers, the whole overlay fades out.
class SplashView extends StatefulWidget {
  const SplashView({required this.onDismiss, super.key});

  /// Called when the splash has finished its exit animation and should be
  /// removed from the tree.
  final VoidCallback onDismiss;

  @override
  State<SplashView> createState() => SplashViewState();
}

class SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  late final Animation<double> _logoOpacity = CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
  );

  late final Animation<double> _logoScale = Tween<double>(begin: 0.82, end: 5.0)
      .animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
        ),
      );

  // Overlay fade-out occupies the tail of the controller timeline.
  late final Animation<double> _overlayOpacity =
      Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
        ),
      );

  bool _exitStarted = false;

  @override
  void initState() {
    super.initState();
    _ctrl
        .animateTo(0.55, duration: const Duration(milliseconds: 1500))
        .whenComplete(startExit);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Called by the parent when auth has resolved and it is safe to exit.
  void startExit() {
    if (_exitStarted) return;
    _exitStarted = true;
    _ctrl
        .animateTo(1.0, duration: const Duration(milliseconds: 500))
        .whenComplete(widget.onDismiss);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Opacity(
          opacity: _overlayOpacity.value,
          child: _FeltSplashBackground(
            child: Center(
              child: Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: const SpLogo(size: 36, showTitle: false),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeltSplashBackground extends StatelessWidget {
  const _FeltSplashBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.2),
          radius: 1.3,
          colors: [SpColors.feltLight, SpColors.felt, SpColors.feltDeep],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: SizedBox.expand(child: child),
    );
  }
}
