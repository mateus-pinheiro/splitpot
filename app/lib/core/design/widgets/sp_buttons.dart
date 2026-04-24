import 'package:flutter/material.dart';

import '../tokens.dart';

/// Botão ouro (CTA principal). Gradient vertical + borda quente + inner
/// shadows (simulados via Stack).
class SpGoldButton extends StatelessWidget {
  const SpGoldButton({
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.fontSize = 16,
    this.icon,
    this.trailing,
    this.padding,
    this.expand = true,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final Widget? icon;
  final Widget? trailing;
  final EdgeInsets? padding;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final child = Opacity(
      opacity: disabled ? 0.55 : 1.0,
      child: Container(
        height: height,
        width: expand ? double.infinity : null,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: SpColors.goldButtonGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x80785014)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 10)],
            if (loading)
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF2A1D08),
                ),
              )
            else
              Text(
                label,
                style: TextStyle(
                  fontFamily: SpTypography.uiFamily,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2A1D08),
                  letterSpacing: 0.25,
                ),
              ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

/// Botão fantasma — borda cream translúcida, bom para ações secundárias.
class SpGhostButton extends StatelessWidget {
  const SpGhostButton({
    required this.label,
    required this.onPressed,
    this.height = 48,
    this.color = SpColors.cream,
    this.borderColor,
    this.fontSize = 14,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final Color color;
  final Color? borderColor;
  final double fontSize;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final border = borderColor ?? SpColors.cream.withValues(alpha: 0.3);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: disabled ? 0.55 : 1.0,
          child: Container(
            height: height,
            width: expand ? double.infinity : null,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: SpTypography.uiFamily,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
