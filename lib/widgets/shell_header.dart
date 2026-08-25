import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../state/session_controller.dart';
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
    // 'kelas' isn't on the real API response yet — falls back to mock data,
    // see AuthenticatedStudent doc in services/auth_service.dart.
    final student = SessionScope.of(context).student;
    final name = student?.name ?? currentStudent.name;
    final initials = student?.initials ?? currentStudent.avatarInitials;
    final kelas = student?.grade ?? currentStudent.kelas;
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
              initials,
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
                  name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: p.ink),
                ),
                Text(
                  kelas,
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
