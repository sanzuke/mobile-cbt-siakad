import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/exam_service.dart';

enum SessionStatus { unknown, signedOut, signedIn }

/// Holds the logged-in student + Sanctum token for the app's lifetime, and
/// restores it from secure storage on cold start. Same InheritedNotifier
/// pattern as [ThemeController]/[ThemeScope] — no external state package.
class SessionController extends ChangeNotifier {
  SessionController({AuthService? authService, ApiClient? apiClient})
      : _authService = authService ?? AuthService(),
        apiClient = apiClient ?? ApiClient() {
    examService = ExamService(this.apiClient);
  }

  final AuthService _authService;
  final ApiClient apiClient;
  late final ExamService examService;

  SessionStatus status = SessionStatus.unknown;
  AuthenticatedStudent? student;

  /// Call once at startup: if a token is already stored, wire it into
  /// [apiClient] optimistically. There's no `/me` endpoint yet to re-fetch
  /// the student profile, so a stored token resumes the API session but the
  /// UI still needs a fresh login to populate [student] after a cold start.
  Future<void> restore() async {
    final token = await _authService.readStoredToken();
    if (token == null) {
      status = SessionStatus.signedOut;
    } else {
      apiClient.setToken(token);
      status = SessionStatus.signedOut; // see restore() doc: no /me endpoint yet
    }
    notifyListeners();
  }

  Future<void> login({
    required String nisn,
    required String birthDate,
    String? deviceName,
  }) async {
    final result = await _authService.login(
      nisn: nisn,
      birthDate: birthDate,
      deviceName: deviceName,
    );
    student = result;
    status = SessionStatus.signedIn;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    student = null;
    status = SessionStatus.signedOut;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.dispose();
    apiClient.dispose();
    super.dispose();
  }
}

class SessionScope extends InheritedNotifier<SessionController> {
  const SessionScope({
    super.key,
    required SessionController controller,
    required super.child,
  }) : super(notifier: controller);

  static SessionController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'SessionScope not found in context');
    return scope!.notifier!;
  }
}
