import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_palette.dart';
import '../widgets/subject_chip.dart';
import 'pre_exam_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Ujian Aktif'),
          const SizedBox(height: 12),
          _ExamCard(exam: activeExam, onStart: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PreExamScreen()),
            );
          }),
          const SizedBox(height: 10),
          _ExamCard(exam: scheduledExam, onStart: null),
          const SizedBox(height: 22),
          _SectionLabel('Riwayat Ujian'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: p.surface,
              border: Border.all(color: p.line),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                for (var i = 0; i < historyEntries.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: p.line),
                  _HistoryRow(entry: historyEntries[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

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

class _ExamCard extends StatelessWidget {
  final ExamSummary exam;
  final VoidCallback? onStart;

  const _ExamCard({required this.exam, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final disabled = onStart == null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SubjectChip(
            label: exam.subjectShort,
            background: disabled ? p.amberSoft : null,
            foreground: disabled ? p.amber : null,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5, color: p.ink),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 14,
                  children: [
                    Text('${exam.questionCount} soal', style: _metaStyle(p)),
                    if (exam.isOpen) Text('${exam.durationMinutes} menit', style: _metaStyle(p)),
                    if (exam.isOpen) Text('Percobaan ${exam.attemptsAllowed}/${exam.attemptsAllowed}', style: _metaStyle(p)),
                    Text(exam.scheduleNote, style: _metaStyle(p)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (disabled)
            Text(
              'Belum dibuka',
              style: TextStyle(color: p.inkFaint, fontSize: 13, fontWeight: FontWeight.w600),
            )
          else
            ElevatedButton(onPressed: onStart, child: const Text('Mulai')),
        ],
      ),
    );
  }

  TextStyle _metaStyle(AppPalette p) =>
      TextStyle(fontFamily: 'monospace', fontSize: 12.5, color: p.inkSoft);
}

class _HistoryRow extends StatelessWidget {
  final HistoryEntry entry;
  const _HistoryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: TextStyle(fontWeight: FontWeight.w600, color: p.ink, fontSize: 13.5)),
                Text(entry.date, style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: p.inkFaint)),
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
  }
}
