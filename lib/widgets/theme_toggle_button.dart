import 'package:flutter/material.dart';

import '../state/theme_controller.dart';
import '../theme/app_palette.dart';

/// Quick light/dark toggle shown in every screen header. The full
/// Terang/Gelap/Otomatis choice lives on the Profile screen.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final controller = ThemeScope.of(context);
    final effective = Theme.of(context).brightness;

    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => controller.toggle(effective),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: p.line),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            effective == Brightness.dark ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
            size: 17,
            color: p.inkSoft,
          ),
        ),
      ),
    );
  }
}
