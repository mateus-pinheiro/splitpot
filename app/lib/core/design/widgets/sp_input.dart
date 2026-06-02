import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens.dart';

/// Input do design system: fundo feltro translúcido, borda dourada sutil,
/// fonte cream. Foco intensifica borda + halo dourado.
class SpInput extends StatelessWidget {
  const SpInput({
    this.controller,
    this.hintText,
    this.initialValue,
    this.enabled = true,
    this.keyboardType,
    this.textAlign,
    this.style,
    this.onChanged,
    this.onSubmitted,
    this.prefix,
    this.suffix,
    this.contentPadding,
    this.inputFormatters,
    this.obscureText = false,
    this.autofillHints,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefix;
  final Widget? suffix;
  final EdgeInsets? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.7,
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        enabled: enabled,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textAlign: textAlign ?? TextAlign.start,
        obscureText: obscureText,
        autofillHints: autofillHints,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        style: style ??
            const TextStyle(
              fontFamily: SpTypography.uiFamily,
              fontSize: 16,
              color: SpColors.cream,
            ),
        cursorColor: SpColors.goldBright,
        decoration: InputDecoration(
          filled: true,
          fillColor: SpColors.feltRail.withValues(alpha: 0.5),
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: SpTypography.uiFamily,
            color: SpColors.cream.withValues(alpha: 0.35),
          ),
          prefixIcon: prefix,
          suffixIcon: suffix,
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpRadius.input),
            borderSide: BorderSide(color: SpColors.gold.withValues(alpha: 0.25)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpRadius.input),
            borderSide: BorderSide(color: SpColors.gold.withValues(alpha: 0.25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpRadius.input),
            borderSide: const BorderSide(color: SpColors.gold, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SpRadius.input),
            borderSide: BorderSide(color: SpColors.gold.withValues(alpha: 0.15)),
          ),
        ),
      ),
    );
  }
}

/// Micro-label dourado uppercase que fica acima de cada input/seção.
class SpFieldLabel extends StatelessWidget {
  const SpFieldLabel(this.text, {this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: (style ?? SpTypography.goldEyebrow).copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
