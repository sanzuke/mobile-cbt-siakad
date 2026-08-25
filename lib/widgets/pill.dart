import 'package:flutter/material.dart';

/// Small status pill, e.g. "Tersambung" / "Tersimpan lokal".
class Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool showDot;

  const Pill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(color: foreground, fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
