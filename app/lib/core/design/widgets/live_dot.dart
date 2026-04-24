import 'package:flutter/material.dart';

/// Bolinha vermelha pulsante (1.6s in-out) usada para indicar "ao vivo".
class LiveDot extends StatefulWidget {
  const LiveDot({this.size = 8, super.key});
  final double size;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = Curves.easeInOut.transform(_c.value);
        final scale = 1.0 + t * 0.15;
        final opacity = 1.0 - t * 0.4;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4444),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x99FF4444), blurRadius: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
