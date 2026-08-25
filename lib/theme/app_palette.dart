import 'package:flutter/material.dart';

/// Design tokens mirrored from the tablet UI mockup (light/dark), exposed as
/// a [ThemeExtension] so widgets read semantic names instead of raw colors.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color paper;
  final Color surface;
  final Color surfaceVariant;
  final Color ink;
  final Color inkSoft;
  final Color inkFaint;
  final Color line;
  final Color accent;
  final Color accentOn;
  final Color accentSoft;
  final Color amber;
  final Color amberSoft;
  final Color danger;
  final Color dangerSoft;
  final Color success;
  final Color successSoft;

  const AppPalette({
    required this.paper,
    required this.surface,
    required this.surfaceVariant,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.line,
    required this.accent,
    required this.accentOn,
    required this.accentSoft,
    required this.amber,
    required this.amberSoft,
    required this.danger,
    required this.dangerSoft,
    required this.success,
    required this.successSoft,
  });

  static const light = AppPalette(
    paper: Color(0xFFEEF1EC),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE2E7E0),
    ink: Color(0xFF16211D),
    inkSoft: Color(0xFF4B5A53),
    inkFaint: Color(0xFF7C8A83),
    line: Color(0xFFC9D2C9),
    accent: Color(0xFF2F6F5E),
    accentOn: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFDBE8E2),
    amber: Color(0xFFA8681B),
    amberSoft: Color(0xFFF2E2C8),
    danger: Color(0xFFA83F2B),
    dangerSoft: Color(0xFFF3DDD6),
    success: Color(0xFF3F7D43),
    successSoft: Color(0xFFDCEAD8),
  );

  // Deliberately softened (not near-black): daytime classroom use on
  // tablets makes a high-contrast dark theme uncomfortable.
  static const dark = AppPalette(
    paper: Color(0xFF171E1B),
    surface: Color(0xFF1E2622),
    surfaceVariant: Color(0xFF242E28),
    ink: Color(0xFFE4E9E3),
    inkSoft: Color(0xFFA7B3AC),
    inkFaint: Color(0xFF77857E),
    line: Color(0xFF333F38),
    accent: Color(0xFF6FB89D),
    accentOn: Color(0xFF0D1613),
    accentSoft: Color(0xFF243830),
    amber: Color(0xFFD9A866),
    amberSoft: Color(0xFF372C1B),
    danger: Color(0xFFDD8973),
    dangerSoft: Color(0xFF3A251F),
    success: Color(0xFF8BC98D),
    successSoft: Color(0xFF243522),
  );

  @override
  AppPalette copyWith({
    Color? paper,
    Color? surface,
    Color? surfaceVariant,
    Color? ink,
    Color? inkSoft,
    Color? inkFaint,
    Color? line,
    Color? accent,
    Color? accentOn,
    Color? accentSoft,
    Color? amber,
    Color? amberSoft,
    Color? danger,
    Color? dangerSoft,
    Color? success,
    Color? successSoft,
  }) {
    return AppPalette(
      paper: paper ?? this.paper,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkFaint: inkFaint ?? this.inkFaint,
      line: line ?? this.line,
      accent: accent ?? this.accent,
      accentOn: accentOn ?? this.accentOn,
      accentSoft: accentSoft ?? this.accentSoft,
      amber: amber ?? this.amber,
      amberSoft: amberSoft ?? this.amberSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      paper: Color.lerp(paper, other.paper, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      line: Color.lerp(line, other.line, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentOn: Color.lerp(accentOn, other.accentOn, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberSoft: Color.lerp(amberSoft, other.amberSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
