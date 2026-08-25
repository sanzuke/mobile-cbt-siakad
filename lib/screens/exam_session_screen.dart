import 'dart:async';

import 'package:flutter/material.dart';

import '../models/exam_models.dart';
import '../state/session_controller.dart';
import '../theme/app_palette.dart';
import '../widgets/pill.dart';
import '../widgets/responsive.dart';
import 'result_screen.dart';

/// Deliberately has no [NavRail]/[ShellHeader] — the exam is locked to a
/// single full-screen flow while a session is in progress.
class ExamSessionScreen extends StatefulWidget {
  final ExamPackage package;

  const ExamSessionScreen({super.key, required this.package});

  @override
  State<ExamSessionScreen> createState() => _ExamSessionScreenState();
}

class _ExamSessionScreenState extends State<ExamSessionScreen> {
  late final List<ExamQuestion> _questions;
  int _current = 0;
  final Set<int> _flagged = {};
  final Map<int, TextEditingController> _essayControllers = {};

  int? _secondsLeft;
  Timer? _countdownTimer;
  Timer? _syncDebounce;
  bool _submitting = false;
  bool _synced = true;

  @override
  void initState() {
    super.initState();
    _questions = widget.package.questions;
    final remaining = widget.package.attempt.timeLimitRemainingSeconds;
    if (remaining != null) {
      _secondsLeft = remaining;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft == null) return;
        if (_secondsLeft! <= 0) {
          _countdownTimer?.cancel();
          _submit(auto: true);
          return;
        }
        setState(() => _secondsLeft = _secondsLeft! - 1);
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _syncDebounce?.cancel();
    for (final c in _essayControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _essayControllerFor(int index) {
    final q = _questions[index];
    return _essayControllers.putIfAbsent(
      index,
      () => TextEditingController(text: q.answerText ?? ''),
    );
  }

  String get _timerLabel {
    final seconds = _secondsLeft;
    if (seconds == null) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toggleFlag() {
    setState(() {
      final id = _questions[_current].examSetQuestionId;
      if (_flagged.contains(id)) {
        _flagged.remove(id);
      } else {
        _flagged.add(id);
      }
    });
  }

  /// Debounced background sync — answers are flushed as the student works,
  /// and again in full right before submit.
  void _scheduleSync() {
    _synced = false;
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 2), () async {
      try {
        await SessionScope.of(context).examService.syncAnswers(
          widget.package.attempt.id,
          [_questions[_current]],
        );
        if (mounted) setState(() => _synced = true);
      } catch (_) {
        // Offline or backend hiccup — stays unsynced, next edit or the
        // pre-submit flush will retry. No local answer queue/persistence
        // yet, so a lost app kill before that retry would drop the answer.
      }
    });
  }

  Future<void> _submit({bool auto = false}) async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final session = SessionScope.of(context);
    try {
      await session.examService.syncAnswers(
        widget.package.attempt.id,
        _questions,
      );
      final result = await session.examService.submit(
        widget.package.attempt.id,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auto
                ? 'Waktu habis tapi gagal mengumpulkan otomatis — coba lagi.'
                : 'Gagal mengumpulkan ujian. Periksa koneksi lalu coba lagi.',
          ),
        ),
      );
    }
  }

  /// Phone-only: the side question-navigator panel doesn't fit next to the
  /// question at narrow widths, so it lives in a modal sheet instead —
  /// opened via the bottom bar. Picking a question or submitting closes the
  /// sheet immediately rather than trying to keep it live-updating.
  void _openNavigatorSheet(BuildContext context) {
    final p = context.palette;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: _QuestionNavigatorPanel(
            questions: _questions,
            flagged: _flagged,
            current: _current,
            submitting: _submitting,
            onSelect: (i) {
              Navigator.pop(sheetContext);
              setState(() => _current = i);
            },
            onSubmit: () {
              Navigator.pop(sheetContext);
              _confirmSubmit(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final question = _questions[_current];
    final answeredCount = _questions.where((q) => q.isAnswered).length;
    final wide = isWideLayout(context);

    final questionColumn = Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOAL ${_current + 1} DARI ${_questions.length}',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              letterSpacing: 1,
              color: p.inkFaint,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              question.text,
              style: TextStyle(fontSize: 17, height: 1.6, color: p.ink),
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: SingleChildScrollView(
              child: question.type.hasOptions
                  ? ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Column(
                        children: [
                          for (var i = 0; i < question.options.length; i++) ...[
                            if (i > 0) const SizedBox(height: 10),
                            _OptionTile(
                              letter: String.fromCharCode(65 + i),
                              text: question.options[i].text,
                              selected: question.selectedOptionIds.contains(
                                question.options[i].id,
                              ),
                              onTap: () => setState(() {
                                question.selectedOptionIds = [
                                  question.options[i].id,
                                ];
                                _scheduleSync();
                              }),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: _EssayField(
                        key: ValueKey('essay-$_current'),
                        controller: _essayControllerFor(_current),
                        onChanged: (text) => setState(() {
                          question.answerText = text.trim().isEmpty
                              ? null
                              : text;
                          _scheduleSync();
                        }),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
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
                onPressed: _current < _questions.length - 1
                    ? () => setState(() => _current++)
                    : null,
                child: const Text('Berikutnya →'),
              ),
            ],
          ),
        ],
      ),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: p.paper,
        body: SafeArea(
          bottom: wide,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: p.surface,
                  border: Border(bottom: BorderSide(color: p.line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.package.examSet.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: p.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Pill(
                      label: _synced ? 'Tersimpan' : 'Menyimpan…',
                      background: _synced ? p.successSoft : p.amberSoft,
                      foreground: _synced ? p.success : p.amber,
                    ),
                    if (_secondsLeft != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
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
                  ],
                ),
              ),
              Expanded(
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: questionColumn),
                          Container(width: 1, color: p.line),
                          SizedBox(
                            width: 230,
                            child: Container(
                              color: p.surfaceVariant,
                              padding: const EdgeInsets.all(20),
                              child: SingleChildScrollView(
                                child: _QuestionNavigatorPanel(
                                  questions: _questions,
                                  flagged: _flagged,
                                  current: _current,
                                  submitting: _submitting,
                                  onSelect: (i) => setState(() => _current = i),
                                  onSubmit: () => _confirmSubmit(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : questionColumn,
              ),
            ],
          ),
        ),
        bottomNavigationBar: wide
            ? null
            : SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: p.surface,
                    border: Border(top: BorderSide(color: p.line)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$answeredCount / ${_questions.length} soal dikerjakan',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: p.inkFaint,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openNavigatorSheet(context),
                        icon: const Icon(Icons.grid_view_rounded, size: 18),
                        label: const Text('Navigasi & Kumpulkan'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _confirmSubmit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kumpulkan ujian?'),
        content: const Text(
          'Jawaban yang belum diisi akan dianggap kosong. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kumpulkan'),
          ),
        ],
      ),
    );
    if (confirmed == true) _submit();
  }
}

/// Free-text answer for essay/fill-in-blank/matching questions. These are
/// hand-graded by the teacher afterwards (see admin-siakad's ExamResults
/// page), unlike MCQ.
class _EssayField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _EssayField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: p.amberSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Soal esai — dikoreksi manual oleh guru, tidak dinilai otomatis',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: p.amber,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 8,
          minLines: 6,
          style: TextStyle(fontSize: 14.5, color: p.ink, height: 1.5),
          decoration: const InputDecoration(
            hintText: 'Tulis jawaban di sini...',
          ),
        ),
      ],
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
                  border: Border.all(
                    color: selected ? p.accent : p.line,
                    width: 1.5,
                  ),
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
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 14.5, color: p.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sync note + question-number grid + legend + submit button. Rendered
/// either inline in the tablet side panel or inside a phone's modal
/// bottom sheet (see [_ExamSessionScreenState._openNavigatorSheet]) — both
/// callers wrap it in a [SingleChildScrollView], so the grid here doesn't
/// scroll on its own.
class _QuestionNavigatorPanel extends StatelessWidget {
  final List<ExamQuestion> questions;
  final Set<int> flagged;
  final int current;
  final bool submitting;
  final ValueChanged<int> onSelect;
  final VoidCallback onSubmit;

  const _QuestionNavigatorPanel({
    required this.questions,
    required this.flagged,
    required this.current,
    required this.submitting,
    required this.onSelect,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final answeredCount = questions.where((q) => q.isAnswered).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 7,
            crossAxisSpacing: 7,
            childAspectRatio: 1,
          ),
          itemCount: questions.length,
          itemBuilder: (context, i) => _NavCell(
            number: i + 1,
            done: questions[i].isAnswered,
            flagged: flagged.contains(questions[i].examSetQuestionId),
            current: i == current,
            onTap: () => onSelect(i),
          ),
        ),
        const SizedBox(height: 12),
        _Legend(color: p.accent, label: 'Terjawab ($answeredCount)'),
        const SizedBox(height: 6),
        _Legend(color: p.amber, label: 'Ragu-ragu (${flagged.length})'),
        const SizedBox(height: 6),
        _Legend(
          color: p.line,
          label: 'Belum dijawab (${questions.length - answeredCount})',
          outlined: true,
        ),
        const SizedBox(height: 14),
        Text(
          '$answeredCount / ${questions.length} soal dikerjakan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11.5,
            color: p.inkFaint,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: submitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(backgroundColor: p.danger),
            child: submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Kumpulkan Ujian'),
          ),
        ),
      ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.all(current ? 2.5 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: current ? Border.all(color: p.ink, width: 2) : null,
      ),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: fg,
              ),
            ),
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

  const _Legend({
    required this.color,
    required this.label,
    this.outlined = false,
  });

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
          child: Text(
            label,
            style: TextStyle(fontSize: 11.5, color: p.inkSoft),
          ),
        ),
      ],
    );
  }
}
