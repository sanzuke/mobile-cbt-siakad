import 'package:flutter/material.dart';

import '../models/exam_models.dart';
import '../state/session_controller.dart';
import '../theme/app_palette.dart';
import '../widgets/nav_rail.dart';
import '../widgets/shell_header.dart';
import '../widgets/subject_chip.dart';
import 'app_shell.dart';
import 'exam_session_screen.dart';

class PreExamScreen extends StatefulWidget {
  final ExamSummary exam;

  const PreExamScreen({super.key, required this.exam});

  @override
  State<PreExamScreen> createState() => _PreExamScreenState();
}

class _PreExamScreenState extends State<PreExamScreen> {
  bool _starting = false;
  String? _error;

  void _goToTab(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AppShell(initialIndex: index)),
      (route) => false,
    );
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      final package = await SessionScope.of(context).examService.startExam(widget.exam.id);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ExamSessionScreen(package: package)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Tidak bisa memulai ujian. Periksa koneksi lalu coba lagi.';
        _starting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final exam = widget.exam;
    return Scaffold(
      backgroundColor: p.paper,
      body: SafeArea(
        child: Row(
          children: [
            NavRail(selectedIndex: -1, onSelect: _goToTab),
            Container(width: 1, color: p.line),
            Expanded(
              child: Column(
                children: [
                  const ShellHeader(),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: p.surface,
                              border: Border.all(color: p.line),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SubjectChip(label: exam.subjectShort),
                                const SizedBox(height: 16),
                                Text(exam.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 22)),
                                const SizedBox(height: 4),
                                Text(exam.subjectName, style: TextStyle(fontSize: 13, color: p.inkSoft)),
                                const SizedBox(height: 22),
                                Row(
                                  children: [
                                    Expanded(child: _StatBox(value: '${exam.questionCount}', label: 'Jumlah Soal')),
                                    const SizedBox(width: 12),
                                    Expanded(child: _StatBox(value: "${exam.durationMinutes}’", label: 'Durasi')),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _StatBox(
                                            value: '${exam.allowedAttempts}×', label: 'Percobaan')),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: p.amberSoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 12.5, color: p.ink, height: 1.6),
                                      children: [
                                        TextSpan(
                                          text: 'Sebelum mulai: ',
                                          style: TextStyle(fontWeight: FontWeight.w700, color: p.amber),
                                        ),
                                        const TextSpan(
                                          text:
                                              'pastikan baterai tablet di atas 20% dan tersambung WiFi sekolah. Jawaban tersimpan otomatis meski koneksi terputus sesaat — ujian akan terkunci ke mode layar penuh selama sesi berlangsung.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: 16),
                                  Text(_error!, style: TextStyle(fontSize: 12.5, color: p.danger)),
                                ],
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _starting ? null : _start,
                                    child: _starting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(exam.inProgressAttemptId != null
                                            ? 'Lanjutkan Ujian'
                                            : 'Mulai Ujian'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: p.paper,
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontFamily: 'monospace', fontSize: 20, fontWeight: FontWeight.w700, color: p.ink)),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 11, color: p.inkFaint)),
        ],
      ),
    );
  }
}
