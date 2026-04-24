import 'package:flutter/material.dart';

import '../tokens.dart';

/// Avatar com iniciais (até 2) e cor determinística pelo primeiro char.
class SpAvatar extends StatelessWidget {
  const SpAvatar({required this.name, this.size = 36, this.bg, super.key});

  final String name;
  final double size;
  final Color? bg;

  static const _palette = <Color>[
    Color(0xFFC0392B),
    Color(0xFF2E8F5A),
    Color(0xFF2C6BA8),
    Color(0xFFA44B8E),
    Color(0xFFB8822B),
    Color(0xFF486A8A),
  ];

  String get _initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
    return letters.toUpperCase();
  }

  Color get _resolvedBg =>
      bg ?? _palette[name.isEmpty ? 0 : name.codeUnitAt(0) % _palette.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _resolvedBg,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Color(0x4D000000), offset: Offset(0, 1), blurRadius: 3),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: SpColors.ivory,
          fontFamily: SpTypography.uiFamily,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
          height: 1.0,
        ),
      ),
    );
  }
}
