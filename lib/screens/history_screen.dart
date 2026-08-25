import 'package:flutter/material.dart';

import '../models/exam_models.dart';
import '../theme/app_palette.dart';

class HistoryScreen extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<HistoryEntry> history;
  final VoidCallback onRefresh;

  const HistoryScreen({
    super.key,
    required this.loading,
    required this.error,
    required this.history,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error!, textAlign: TextAlign.center, style: TextStyle(color: p.inkSoft)),
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onRefresh, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    if (history.isEmpty) {
      return Center(
        child: Text('Belum ada riwayat ujian.', style: TextStyle(color: p.inkFaint, fontSize: 13.5)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
        itemCount: history.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final entry = history[i];
          final pending = entry.pendingGrading;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
              color: p.surface,
              border: Border.all(color: p.line),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.title,
                          style: TextStyle(fontWeight: FontWeight.w600, color: p.ink, fontSize: 14)),
                      Text(
                        entry.submittedAt != null ? _formatDate(entry.submittedAt!) : '-',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: p.inkFaint),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pending ? p.surfaceVariant : p.successSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pending
                        ? 'Menunggu koreksi'
                        : '${entry.percentage?.toStringAsFixed(0) ?? '-'} / 100',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: pending ? p.inkSoft : p.success,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', //
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String _formatDate(DateTime dt) => '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
}
