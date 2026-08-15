import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/exam_service.dart';

enum SessionStatus { unknown, signedOut, signedIn }

/// Holds the logged-in student + Sanctum token for the app's lifetime, and
/// restores it from secure storage on cold start. Same InheritedNotifier
/// pattern as [ThemeController]/[ThemeScope] — no external state package.
///
/// [AuthService] and [ExamService] deliberately share a single [ApiClient]
/// instance (constructed here, never separately) — otherwise a token set by
/// a login call on one client never reaches the other, and every
/// [examService] call after login would 401. Only [storage] is injectable
/// (for tests that need to fake secure storage), not a whole [AuthService].
class SessionController extends ChangeNotifier {
  SessionController({ApiClient? apiClient, FlutterSecureStorage? storage})
      : apiClient = apiClient ?? ApiClient() {
    _authService = AuthService(client: this.apiClient, storage: storage);
    examService = ExamService(this.apiClient);
  }

  late final AuthService _authService;
  final ApiClient apiClient;
  late final ExamService examService;

  SessionStatus status = SessionStatus.unknown;
  AuthenticatedStudent? student;

  /// Call once at startup: if a token is stored, wire it into [apiClient]
  /// and re-fetch the profile via `/me` so the app can resume straight past
  /// the login screen. Falls back to signed-out if there's no token, or the
  /// stored one turns out to be expired/revoked server-side.
  Future<void> restore() async {
    final token = await _authService.readStoredToken();
    if (token == null) {
      status = SessionStatus.signedOut;
      notifyListeners();
      return;
    }

    apiClient.setToken(token);
    try {
      student = await _authService.fetchMe();
      status = SessionStatus.signedIn;
    } on ApiException {
      // Stored token is invalid/expired server-side — purge it (not just the
      // in-memory copy on apiClient) so restore() doesn't keep retrying a
      // dead token on every future cold start.
      await _authService.logout();
      status = SessionStatus.signedOut;
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
