import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_palette.dart';
import '../widgets/pill.dart';
import 'result_screen.dart';

/// Deliberately has no [NavRail]/[ShellHeader] — the exam is locked to a
/// single full-screen flow while a session is in progress.
class ExamSessionScreen extends StatefulWidget {
  const ExamSessionScreen({super.key});

  @override
  State<ExamSessionScreen> createState() => _ExamSessionScreenState();
}

class _ExamSessionScreenState extends State<ExamSessionScreen> {
  // Demo starts mid-exam so the nav grid shows a realistic mix of states.
  int _current = 5;
  final Map<int, int> _answers = {0: 0, 1: 1, 2: 2, 3: 0, 4: 3, 5: 0};
  final Set<int> _flagged = {6};
  late int _secondsLeft = 42 * 60 + 17;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toggleFlag() {
    setState(() {
      if (_flagged.contains(_current)) {
        _flagged.remove(_current);
      } else {
        _flagged.add(_current);
      }
    });
  }

  void _submit() {
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ResultScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final question = fiqihQuestions[_current];
    return Scaffold(
      backgroundColor: p.paper,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: p.surface,
                border: Border(bottom: BorderSide(color: p.line)),
              ),
              child: Row(
                children: [
                  Text('Fiqih · Ulangan Harian',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: p.ink)),
                  const SizedBox(width: 12),
                  Pill(label: 'Tersimpan lokal', background: p.amberSoft, foreground: p.amber),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: p.dangerSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _timerLabel,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: p.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOAL ${_current + 1} DARI ${fiqihQuestions.length}',
                            style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                letterSpacing: 1,
                                color: p.inkFaint),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: Text(question.text,
                                style: TextStyle(fontSize: 17, height: 1.6, color: p.ink)),
                          ),
                          const SizedBox(height: 22),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: Column(
                              children: [
                                for (var i = 0; i < question.options.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 10),
                                  _OptionTile(
                                    letter: String.fromCharCode(65 + i),
                                    text: question.options[i],
                                    selected: _answers[_current] == i,
                                    onTap: () => setState(() => _answers[_current] = i),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: _current > 0
                                    ? () => setState(() => _current--)
                                    : null,
                                child: const Text('← Sebelumnya'),
                              ),
                              const Spacer(),
                              OutlinedButton(
                                onPressed: _toggleFlag,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: p.amberSoft,
                                  foregroundColor: p.amber,
                                  side: BorderSide.none,
                                ),
                                child: const Text('🚩 Ragu-ragu'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _current < fiqihQuestions.length - 1
                                    ? () => setState(() => _current++)
                                    : null,
                                child: const Text('Berikutnya →'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, color: p.line),
                  SizedBox(
                    width: 230,
                    child: Container(
                      color: p.surfaceVariant,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('⟳', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Jawaban disinkron otomatis saat WiFi tersambung kembali.',
                                  style: TextStyle(fontSize: 11, color: p.inkFaint, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: p.line, height: 1),
                          const SizedBox(height: 16),
                          Text(
                            'NAVIGASI SOAL',
                            style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                letterSpacing: 1.2,
                                color: p.inkFaint,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                mainAxisSpacing: 7,
                                crossAxisSpacing: 7,
                                childAspectRatio: 1,
                              ),
                              itemCount: fiqihQuestions.length,
                              itemBuilder: (context, i) => _NavCell(
                                number: i + 1,
                                done: _answers.containsKey(i),
                                flagged: _flagged.contains(i),
                                current: i == _current,
                                onTap: () => setState(() => _current = i),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Legend(
                              color: p.accent, label: 'Terjawab (${_answers.length})'),
                          const SizedBox(height: 6),
                          _Legend(color: p.amber, label: 'Ragu-ragu (${_flagged.length})'),
                          const SizedBox(height: 6),
                          _Legend(
                            color: p.line,
                            label:
                                'Belum dijawab (${fiqihQuestions.length - _answers.length})',
                            outlined: true,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${_answers.length} / ${fiqihQuestions.length} soal dikerjakan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'monospace', fontSize: 11.5, color: p.inkFaint),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(backgroundColor: p.danger),
                              child: const Text('Kumpulkan Ujian'),
                            ),
                          ),
                        ],
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

class _OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: selected ? p.accentSoft : p.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? p.accent : p.line, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? p.accent : Colors.transparent,
                  border: Border.all(color: selected ? p.accent : p.line, width: 1.5),
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? p.accentOn : p.inkSoft,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: TextStyle(fontSize: 14.5, color: p.ink))),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  final int number;
  final bool done;
  final bool flagged;
  final bool current;
  final VoidCallback onTap;

  const _NavCell({
    required this.number,
    required this.done,
    required this.flagged,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Color bg = p.surface;
    Color fg = p.inkSoft;
    Color border = p.line;
    if (done) {
      bg = p.accent;
      fg = p.accentOn;
      border = p.accent;
    } else if (flagged) {
      bg = p.amberSoft;
      fg = p.amber;
      border = p.amber;
    }
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: current ? 2 : 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 12.5, color: fg),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool outlined;

  const _Legend({required this.color, required this.label, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: outlined ? p.surface : color,
            borderRadius: BorderRadius.circular(4),
            border: outlined ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 11.5, color: p.inkSoft)),
        ),
      ],
    );
  }
}
