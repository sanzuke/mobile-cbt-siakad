import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_palette.dart';
import 'pill.dart';
import 'theme_toggle_button.dart';

/// Top bar shown on every screen inside the app shell: student identity,
/// connectivity status, and the quick theme toggle.
class ShellHeader extends StatelessWidget {
  final bool online;

  const ShellHeader({super.key, this.online = true});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: p.accentSoft,
            child: Text(
              currentStudent.avatarInitials,
              style: TextStyle(color: p.accent, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentStudent.name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: p.ink),
                ),
                Text(
                  currentStudent.kelas,
                  style: TextStyle(fontSize: 12, color: p.inkFaint),
                ),
              ],
            ),
          ),
          Pill(
            label: online ? 'Tersambung' : 'Tersimpan lokal',
            background: online ? p.successSoft : p.amberSoft,
            foreground: online ? p.success : p.amber,
          ),
          const SizedBox(width: 10),
          const ThemeToggleButton(),
        ],
      ),
    );
  }
}
