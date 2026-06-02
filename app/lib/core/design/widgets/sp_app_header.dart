import 'package:flutter/material.dart';

import '../tokens.dart';
import 'live_dot.dart';

/// Header padrão das telas. Três slots fixos (left, center, right) com
/// alinhamento óptico no centro da linha e da coluna. Mantém altura mínima
/// constante para evitar saltos visuais entre páginas.
class SpAppHeader extends StatelessWidget {
  const SpAppHeader({
    this.left,
    this.title,
    this.subtitle,
    this.right,
    super.key,
  });

  static const double _minHeight = 56;
  static const double _slotWidth = 48;

  final Widget? left;
  final String? title;
  final Widget? subtitle;
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(SpSpacing.lg, 4, SpSpacing.lg, 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minHeight),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Slot(alignment: Alignment.centerLeft, child: left),
            Expanded(child: _Title(title: title, subtitle: subtitle)),
            _Slot(alignment: Alignment.centerRight, child: right),
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.alignment, this.child});

  final AlignmentGeometry alignment;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SpAppHeader._slotWidth,
      height: SpAppHeader._slotWidth,
      child: child == null ? null : Align(alignment: alignment, child: child),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({this.title, this.subtitle});

  final String? title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    if (title == null && subtitle == null) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (title != null)
          Text(
            title!,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: SpTypography.displayFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: SpColors.cream,
              height: 1.15,
            ),
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          DefaultTextStyle(
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 11,
              color: SpColors.muted,
              letterSpacing: 0.55,
            ),
            child: subtitle!,
          ),
        ],
      ],
    );
  }
}

/// Back arrow estilizado (gold). Hit area fixa 40×40 para alinhar opticamente
/// dentro do slot do [SpAppHeader].
class SpBackButton extends StatelessWidget {
  const SpBackButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      color: SpColors.goldBright,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      splashRadius: 22,
    );
  }
}

/// "Ao vivo" label com dot vermelho pulsante.
class SpLiveLabel extends StatelessWidget {
  const SpLiveLabel({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const LiveDot(),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: SpTypography.uiFamily,
            fontSize: 11,
            color: SpColors.muted,
            letterSpacing: 0.55,
          ),
        ),
      ],
    );
  }
}
