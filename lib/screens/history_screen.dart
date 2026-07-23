import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_palette.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
      itemCount: historyEntries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final entry = historyEntries[i];
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
                    Text(entry.date,
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: p.inkFaint)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: entry.pending ? p.surfaceVariant : p.successSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.pending ? 'Menunggu koreksi' : '${entry.score} / 100',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: entry.pending ? p.inkSoft : p.success,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
