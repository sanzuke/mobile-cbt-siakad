import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_client.dart';

/// Mirrors `StudentResource` on the backend (`app/Http/Resources/Api/Student/StudentResource.php`).
/// Deliberately narrower than the old mock `Student` (no wali/birth-date/device
/// fields — the API doesn't return those yet) — screens still reading those
/// mock fields haven't been migrated over, see the mobile-cbt-siakad TODOs.
class AuthenticatedStudent {
  const AuthenticatedStudent({
    required this.id,
    required this.name,
    required this.nisn,
    this.nis,
    this.grade,
    this.photoUrl,
  });

  final int id;
  final String name;
  final String nisn;
  final String? nis;
  final String? grade;
  final String? photoUrl;

  factory AuthenticatedStudent.fromJson(Map<String, dynamic> json) {
    return AuthenticatedStudent(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      nisn: json['nisn'] as String? ?? '',
      nis: json['nis'] as String?,
      grade: json['grade'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

/// Wraps `/api/v1/student/login` and `/logout`, and persists the Sanctum
/// bearer token in secure storage so the session survives an app restart.
class AuthService {
  AuthService({ApiClient? client, FlutterSecureStorage? storage})
      : _client = client ?? ApiClient(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'student_api_token';

  final ApiClient _client;
  final FlutterSecureStorage _storage;

  Future<String?> readStoredToken() => _storage.read(key: _tokenKey);

  /// [birthDate] must be `yyyy-MM-dd`, matching the backend's `date` validation
  /// rule — callers are responsible for converting whatever the field UI uses.
  Future<AuthenticatedStudent> login({
    required String nisn,
    required String birthDate,
    String? deviceName,
  }) async {
    final data = await _client.post('/v1/student/login', body: {
      'nisn': nisn,
      'birth_date': birthDate,
      'device_name': ?deviceName,
    }) as Map<String, dynamic>;

    final token = data['token'] as String;
    await _storage.write(key: _tokenKey, value: token);
    _client.setToken(token);

    return AuthenticatedStudent.fromJson(data['student'] as Map<String, dynamic>);
  }

  /// Re-fetches the profile for whatever token is currently set on
  /// [ApiClient] — used to resume a session after a cold start, when the
  /// stored token survives but the in-memory [AuthenticatedStudent] doesn't.
  /// Throws [ApiException] if the token is missing/expired; callers should
  /// treat that as "not logged in" and fall back to the login screen.
  Future<AuthenticatedStudent> fetchMe() async {
    final data = await _client.get('/v1/student/me') as Map<String, dynamic>;
    return AuthenticatedStudent.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await _client.post('/v1/student/logout');
    } on ApiException {
      // Token already invalid/expired server-side — fine, we're clearing it
      // locally regardless.
    } finally {
      await _storage.delete(key: _tokenKey);
      _client.setToken(null);
    }
  }
}
