import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../screens/login_screen.dart';
import '../state/session_controller.dart';
import '../state/theme_controller.dart';
import '../theme/app_palette.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // The API doesn't return kelas/wali/device fields yet (see
    // AuthenticatedStudent doc), so those still fall back to mock data —
    // only name/NISN/avatar come from the real logged-in session.
    final student = SessionScope.of(context).student;
    final name = student?.name ?? currentStudent.name;
    final nisn = student?.nisn ?? currentStudent.nisn;
    final initials = student?.initials ?? currentStudent.avatarInitials;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 26),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: p.surface,
                border: Border.all(color: p.line),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: p.accentSoft,
                    child: Text(
                      initials,
                      style: TextStyle(color: p.accent, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: p.ink)),
                      Text('NISN $nisn',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: p.inkFaint)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _Label('Data Siswa'),
            const SizedBox(height: 12),
            _InfoList(rows: [
              ('Kelas', currentStudent.kelas),
              ('Tanggal Lahir', currentStudent.birthDate),
              ('Wali Santri', currentStudent.waliName),
              ('Kontak Wali', currentStudent.waliContact),
            ]),
            const SizedBox(height: 22),
            _Label('Tampilan'),
            const SizedBox(height: 12),
            const _ThemeSegment(),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: p.accentSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12.5, color: p.ink, height: 1.5),
                  children: [
                    const TextSpan(text: '📱  '),
                    TextSpan(
                      text: 'Tablet terdaftar: ',
                      style: TextStyle(fontWeight: FontWeight.w700, color: p.accent),
                    ),
                    TextSpan(
                      text:
                          '${currentStudent.deviceLabel}. Ganti perangkat perlu persetujuan wali kelas / admin.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final session = SessionScope.of(context);
                  await session.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.danger,
                  side: BorderSide(color: p.danger, width: 1.5),
                ),
                child: const Text('Keluar dari Akun'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 11,
        letterSpacing: 1.2,
        color: p.inkFaint,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoList extends StatelessWidget {
  final List<(String, String)> rows;
  const _InfoList({required this.rows});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: p.line),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(rows[i].$1, style: TextStyle(color: p.inkFaint, fontSize: 13.5)),
                  Text(rows[i].$2,
                      style: TextStyle(color: p.ink, fontWeight: FontWeight.w600, fontSize: 13.5)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final controller = ThemeScope.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: p.paper,
            border: Border.all(color: p.line),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              _segButton(context, ThemeMode.light, Icons.wb_sunny_outlined, 'Terang'),
              _segButton(context, ThemeMode.dark, Icons.nightlight_outlined, 'Gelap'),
              _segButton(context, ThemeMode.system, Icons.tablet_mac_outlined, 'Otomatis'),
            ],
          ),
        );
      },
    );
  }

  Widget _segButton(BuildContext context, ThemeMode mode, IconData icon, String label) {
    final p = context.palette;
    final controller = ThemeScope.of(context);
    final active = controller.mode == mode;
    return Expanded(
      child: Material(
        color: active ? p.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        elevation: active ? 1 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => controller.setMode(mode),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: active ? p.accent : p.inkSoft),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: active ? p.accent : p.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
