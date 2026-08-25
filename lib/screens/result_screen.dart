import 'package:flutter/material.dart';

import '../models/exam_models.dart';
import '../theme/app_palette.dart';
import '../widgets/nav_rail.dart';
import '../widgets/shell_header.dart';
import 'app_shell.dart';

class ResultScreen extends StatelessWidget {
  final ExamResult result;

  const ResultScreen({super.key, required this.result});

  void _goToTab(BuildContext context, int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AppShell(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final percentage = result.percentage;
    final pending = !result.isFinal;

    return Scaffold(
      backgroundColor: p.paper,
      body: SafeArea(
        child: Row(
          children: [
            NavRail(selectedIndex: 2, onSelect: (i) => _goToTab(context, i)),
            Container(width: 1, color: p.line),
            Expanded(
              child: Column(
                children: [
                  const ShellHeader(),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Container(
                          padding: const EdgeInsets.all(34),
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: p.surface,
                            border: Border.all(color: p.line),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: CircularProgressIndicator(
                                        value: percentage != null ? percentage / 100 : null,
                                        strokeWidth: 10,
                                        backgroundColor: p.surfaceVariant,
                                        color: pending ? p.amber : p.success,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          percentage != null ? percentage.toStringAsFixed(0) : '—',
                                          style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 28,
                                              fontWeight: FontWeight.w700,
                                              color: p.ink),
                                        ),
                                        Text('dari 100',
                                            style: TextStyle(fontSize: 11, color: p.inkFaint)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(result.examSetTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 20, color: p.ink)),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: pending
                                      ? p.amberSoft
                                      : (result.passed == true ? p.successSoft : p.dangerSoft),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  pending
                                      ? '⏳ Menunggu koreksi soal esai'
                                      : (result.passed == true
                                          ? '✓ Lulus KKM (${result.passingScore?.toStringAsFixed(0) ?? '-'})'
                                          : '✗ Belum mencapai KKM (${result.passingScore?.toStringAsFixed(0) ?? '-'})'),
                                  style: TextStyle(
                                      color: pending
                                          ? p.amber
                                          : (result.passed == true ? p.success : p.danger),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5),
                                ),
                              ),
                              const SizedBox(height: 22),
                              _ResultRow(
                                  label: 'Dikerjakan',
                                  value: '${result.answeredCount} / ${result.questionCount} soal'),
                              const SizedBox(height: 10),
                              _ResultRow(label: 'Waktu digunakan', value: result.timeSpentLabel),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _goToTab(context, 0),
                                  child: const Text('Kembali ke Dashboard'),
                                ),
                              ),
                            ],
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

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: p.paper, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.5, color: p.ink)),
          Text(value,
              style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 13.5, color: p.ink)),
        ],
      ),
    );
  }
}
