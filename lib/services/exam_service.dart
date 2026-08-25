import '../models/exam_models.dart';
import 'api_client.dart';

/// Wraps the exam-taking endpoints of `/api/v1/student/*`
/// (`ExamController`, `AttemptController`, `DashboardController`).
class ExamService {
  ExamService(this._client);

  final ApiClient _client;

  Future<DashboardData> fetchDashboard() async {
    final data = await _client.get('/v1/student/dashboard') as Map<String, dynamic>;
    return DashboardData.fromJson(data);
  }

  /// Starts a fresh attempt, or resumes the in-progress one if the student
  /// already started this exam set.
  Future<ExamPackage> startExam(int examSetId) async {
    final data = await _client.post('/v1/student/exams/$examSetId/start') as Map<String, dynamic>;
    return ExamPackage.fromJson(data);
  }

  /// Re-fetches attempt + questions — used to resume after the app was
  /// killed/backgrounded mid-exam.
  Future<ExamPackage> resumeAttempt(int attemptId) async {
    final data = await _client.get('/v1/student/attempts/$attemptId') as Map<String, dynamic>;
    return ExamPackage.fromJson(data);
  }

  /// Batch answer sync — safe to call repeatedly with the same question
  /// (idempotent `updateOrCreate` server-side).
  Future<void> syncAnswers(int attemptId, List<ExamQuestion> answers) async {
    if (answers.isEmpty) return;
    await _client.put('/v1/student/attempts/$attemptId/answers', body: {
      'answers': [
        for (final q in answers)
          {
            'exam_set_question_id': q.examSetQuestionId,
            'option_ids': q.selectedOptionIds,
            'text': q.answerText,
          },
      ],
    });
  }

  Future<ExamResult> submit(int attemptId) async {
    final data = await _client.post('/v1/student/attempts/$attemptId/submit') as Map<String, dynamic>;
    return ExamResult.fromJson(data);
  }

  Future<ExamResult> fetchResult(int attemptId) async {
    final data = await _client.get('/v1/student/attempts/$attemptId/result') as Map<String, dynamic>;
    return ExamResult.fromJson(data);
  }
}
