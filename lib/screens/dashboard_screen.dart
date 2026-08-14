import 'package:flutter/material.dart';

import '../models/exam_models.dart';
import '../theme/app_palette.dart';
import '../widgets/subject_chip.dart';
import 'pre_exam_screen.dart';

class DashboardScreen extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<ExamSummary> exams;
  final VoidCallback onRefresh;

  const DashboardScreen({
    super.key,
    required this.loading,
    required this.error,
    required this.exams,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return _ErrorState(message: error!, onRetry: onRefresh);
    }

    final openExams = exams.where((e) => e.isOpen).toList();
    final upcomingExams = exams.where((e) => !e.isOpen).toList();

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('Ujian Aktif'),
            const SizedBox(height: 12),
            if (openExams.isEmpty && upcomingExams.isEmpty)
              Text('Belum ada ujian untuk kelas Anda.',
                  style: TextStyle(color: p.inkFaint, fontSize: 13.5))
            else ...[
              for (final exam in openExams) ...[
                _ExamCard(exam: exam),
                const SizedBox(height: 10),
              ],
              for (final exam in upcomingExams) ...[
                _ExamCard(exam: exam),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
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

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final disabled = !exam.canStart;
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
                    if (exam.isOpen)
                      Text('Percobaan ${exam.attemptsUsed}/${exam.allowedAttempts}', style: _metaStyle(p)),
                    Text(exam.scheduleNote, style: _metaStyle(p)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (disabled)
            Text(
              exam.isOpen ? 'Percobaan habis' : 'Belum dibuka',
              style: TextStyle(color: p.inkFaint, fontSize: 13, fontWeight: FontWeight.w600),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PreExamScreen(exam: exam)),
                );
              },
              child: Text(exam.inProgressAttemptId != null ? 'Lanjutkan' : 'Mulai'),
            ),
        ],
      ),
    );
  }

  TextStyle _metaStyle(AppPalette p) =>
      TextStyle(fontFamily: 'monospace', fontSize: 12.5, color: p.inkSoft);
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: p.inkSoft)),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
