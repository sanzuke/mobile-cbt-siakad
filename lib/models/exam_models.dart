/// Mirrors `QuestionBank::TYPE_*` on the backend (`app/Models/QuestionBank.php`).
/// The tablet UI renders two shapes: `options` non-empty → choice tiles,
/// otherwise → free-text field (covers essay, fill_in_blank, and matching —
/// matching doesn't have a dedicated drag/match widget yet, so it falls back
/// to free text, which a teacher can still hand-grade).
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInBlank,
  essay,
  matching;

  static QuestionType fromApi(String value) => switch (value) {
        'multiple_choice' => QuestionType.multipleChoice,
        'true_false' => QuestionType.trueFalse,
        'fill_in_blank' => QuestionType.fillInBlank,
        'essay' => QuestionType.essay,
        'matching' => QuestionType.matching,
        _ => QuestionType.essay,
      };

  bool get hasOptions => this == multipleChoice || this == trueFalse;
}

/// One row of `/api/v1/student/dashboard` or `/exams` — `ExamSetResource` on
/// the backend.
class ExamSummary {
  const ExamSummary({
    required this.id,
    required this.title,
    required this.subjectName,
    required this.subjectShort,
    required this.questionCount,
    required this.durationMinutes,
    required this.allowedAttempts,
    required this.attemptsUsed,
    required this.isOpen,
    required this.canStart,
    required this.startTime,
    required this.endTime,
    required this.inProgressAttemptId,
  });

  final int id;
  final String title;
  final String subjectName;
  final String subjectShort;
  final int questionCount;
  final int durationMinutes;
  final int allowedAttempts;
  final int attemptsUsed;
  final bool isOpen;
  final bool canStart;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? inProgressAttemptId;

  factory ExamSummary.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>?;
    return ExamSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      subjectName: subject?['name'] as String? ?? '',
      subjectShort: subject?['short_code'] as String? ?? '?',
      questionCount: json['question_count'] as int? ?? 0,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      allowedAttempts: json['allowed_attempts'] as int? ?? 1,
      attemptsUsed: json['attempts_used'] as int? ?? 0,
      isOpen: json['is_open'] as bool? ?? false,
      canStart: json['can_start'] as bool? ?? false,
      startTime: DateTime.tryParse(json['start_time'] as String? ?? ''),
      endTime: DateTime.tryParse(json['end_time'] as String? ?? ''),
      inProgressAttemptId: json['in_progress_attempt_id'] as int?,
    );
  }

  /// Short note under the exam card — best-effort from `start_time`/`end_time`,
  /// which is all the resource gives us (no free-text schedule note field).
  String get scheduleNote {
    if (isOpen && endTime != null) {
      return 'Tutup ${_time(endTime!)}';
    }
    if (!isOpen && startTime != null) {
      return 'Dibuka ${_dateTime(startTime!)}';
    }
    return isOpen ? 'Sedang berlangsung' : 'Belum dibuka';
  }

  static String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  static String _dateTime(DateTime dt) => '${dt.day}/${dt.month} ${_time(dt)}';
}

class HistoryEntry {
  const HistoryEntry({
    required this.attemptId,
    required this.examSetId,
    required this.title,
    required this.submittedAt,
    required this.status,
    required this.percentage,
    required this.pendingGrading,
  });

  final int attemptId;
  final int examSetId;
  final String title;
  final DateTime? submittedAt;
  final String status;
  final double? percentage;
  final bool pendingGrading;

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      attemptId: json['attempt_id'] as int,
      examSetId: json['exam_set_id'] as int,
      title: json['title'] as String? ?? '',
      submittedAt: DateTime.tryParse(json['submitted_at'] as String? ?? ''),
      status: json['status'] as String? ?? '',
      percentage: (json['percentage'] as num?)?.toDouble(),
      pendingGrading: json['pending_grading'] as bool? ?? false,
    );
  }
}

class DashboardData {
  const DashboardData({required this.exams, required this.history});

  final List<ExamSummary> exams;
  final List<HistoryEntry> history;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      exams: (json['exams'] as List<dynamic>? ?? [])
          .map((e) => ExamSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      history: (json['history'] as List<dynamic>? ?? [])
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionOption {
  const QuestionOption({required this.id, required this.text, this.imageUrl});

  final int id;
  final String text;
  final String? imageUrl;

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as int,
      text: json['text'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
    );
  }
}

/// `QuestionResource` — `examSetQuestionId` (not the underlying question-bank
/// id) is what gets sent back when syncing/submitting answers.
class ExamQuestion {
  ExamQuestion({
    required this.examSetQuestionId,
    required this.type,
    required this.text,
    required this.points,
    required this.options,
    this.imageUrl,
    List<int>? selectedOptionIds,
    this.answerText,
  }) : selectedOptionIds = selectedOptionIds ?? [];

  final int examSetQuestionId;
  final QuestionType type;
  final String text;
  final String? imageUrl;
  final double points;
  final List<QuestionOption> options;

  // Mutable local answer state — kept on the model so the exam session
  // screen doesn't need a parallel by-id map.
  List<int> selectedOptionIds;
  String? answerText;

  bool get isAnswered =>
      selectedOptionIds.isNotEmpty || (answerText != null && answerText!.trim().isNotEmpty);

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    final answer = json['answer'] as Map<String, dynamic>?;
    final optionIds = (answer?['option_ids'] as List<dynamic>?)?.cast<int>();
    return ExamQuestion(
      examSetQuestionId: json['exam_set_question_id'] as int,
      type: QuestionType.fromApi(json['type'] as String? ?? 'essay'),
      text: json['text'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      points: (json['points'] as num?)?.toDouble() ?? 0,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((o) => QuestionOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      selectedOptionIds: optionIds ?? [],
      answerText: answer?['text'] as String?,
    );
  }
}

class ExamAttempt {
  const ExamAttempt({
    required this.id,
    required this.examSetId,
    required this.status,
    required this.attemptNumber,
    required this.timeLimitRemainingSeconds,
  });

  final int id;
  final int examSetId;
  final String status;
  final int attemptNumber;
  final int? timeLimitRemainingSeconds;

  factory ExamAttempt.fromJson(Map<String, dynamic> json) {
    return ExamAttempt(
      id: json['id'] as int,
      examSetId: json['exam_set_id'] as int,
      status: json['status'] as String? ?? '',
      attemptNumber: json['attempt_number'] as int? ?? 1,
      timeLimitRemainingSeconds: json['time_limit_remaining_seconds'] as int?,
    );
  }
}

/// Full offline-cacheable payload from `/exams/{id}/start` or
/// `/attempts/{id}` — `exam_set`, `attempt`, `questions`.
class ExamPackage {
  const ExamPackage({required this.examSet, required this.attempt, required this.questions});

  final ExamSummary examSet;
  final ExamAttempt attempt;
  final List<ExamQuestion> questions;

  factory ExamPackage.fromJson(Map<String, dynamic> json) {
    return ExamPackage(
      examSet: ExamSummary.fromJson(json['exam_set'] as Map<String, dynamic>),
      attempt: ExamAttempt.fromJson(json['attempt'] as Map<String, dynamic>),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => ExamQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExamResult {
  const ExamResult({
    required this.id,
    required this.examSetTitle,
    required this.passingScore,
    required this.status,
    required this.isFinal,
    required this.totalScore,
    required this.maxScore,
    required this.percentage,
    required this.passed,
    required this.answeredCount,
    required this.questionCount,
    required this.timeSpentSeconds,
  });

  final int id;
  final String examSetTitle;
  final double? passingScore;
  final String status;
  final bool isFinal;
  final double? totalScore;
  final double? maxScore;
  final double? percentage;
  final bool? passed;
  final int answeredCount;
  final int questionCount;
  final int? timeSpentSeconds;

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    final examSet = json['exam_set'] as Map<String, dynamic>;
    return ExamResult(
      id: json['id'] as int,
      examSetTitle: examSet['title'] as String? ?? '',
      passingScore: (examSet['passing_score'] as num?)?.toDouble(),
      status: json['status'] as String? ?? '',
      isFinal: json['is_final'] as bool? ?? false,
      totalScore: (json['total_score'] as num?)?.toDouble(),
      maxScore: (json['max_score'] as num?)?.toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      passed: json['passed'] as bool?,
      answeredCount: json['answered_count'] as int? ?? 0,
      questionCount: json['question_count'] as int? ?? 0,
      timeSpentSeconds: json['time_spent_seconds'] as int?,
    );
  }

  String get timeSpentLabel {
    final seconds = timeSpentSeconds;
    if (seconds == null) return '-';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m menit $s detik';
  }
}
