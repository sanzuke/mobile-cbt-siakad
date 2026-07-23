import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Placeholder for the learning-materials extension described in
/// admin-siakad/docs/CBT_MOBILE_APP_PLAN.md §7 — not built yet.
class MateriScreen extends StatelessWidget {
  const MateriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 40, color: p.inkFaint),
          const SizedBox(height: 12),
          Text(
            'Materi belajar segera hadir',
            style: TextStyle(fontWeight: FontWeight.w600, color: p.ink, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Akses PDF materi pembelajaran akan tersedia di sini.',
            style: TextStyle(color: p.inkFaint, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
