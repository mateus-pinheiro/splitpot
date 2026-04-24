import 'package:flutter/material.dart';

import '../tokens.dart';
import 'live_dot.dart';

/// Cabeçalho das telas — left (back/avatar), title centralizado, right.
class SpAppHeader extends StatelessWidget {
  const SpAppHeader({
    this.left,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.right,
    super.key,
  });

  final Widget? left;
  final String? title;
  final Widget? titleWidget;
  final Widget? subtitle;
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 48, child: left ?? const SizedBox.shrink()),
          Expanded(
            child: Column(
              children: [
                ?titleWidget,
                if (titleWidget == null && title != null)
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: SpTypography.displayFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: SpColors.cream,
                      height: 1.1,
                    ),
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle(
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
            ),
          ),
          SizedBox(
            width: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: right ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Back arrow estilizado (cream/gold).
class SpBackButton extends StatelessWidget {
  const SpBackButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      color: SpColors.goldBright,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
      splashRadius: 20,
    );
  }
}

/// Pulsing "ao vivo" label com dot vermelho.
class SpLiveLabel extends StatelessWidget {
  const SpLiveLabel({required this.text, super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
