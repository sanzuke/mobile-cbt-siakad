import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Square rounded chip showing a subject's short code (e.g. "FQ", "MTK").
class SubjectChip extends StatelessWidget {
  final String label;
  final Color? background;
  final Color? foreground;
  final double size;

  const SubjectChip({
    super.key,
    required this.label,
    this.background,
    this.foreground,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? p.accentSoft,
        borderRadius: BorderRadius.circular(size * 0.23),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground ?? p.accent,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}
