import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_cbt_siakad/main.dart';
import 'package:mobile_cbt_siakad/services/auth_service.dart';
import 'package:mobile_cbt_siakad/state/session_controller.dart';

/// In-memory stand-in for [FlutterSecureStorage] — the real one talks to
/// native platform APIs (Windows Credential Manager via FFI, Keychain,
/// etc.) even under `flutter test`, which isn't available/safe in a
/// headless test run.
class _FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }
}

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    final session = SessionController(
      authService: AuthService(storage: _FakeSecureStorage()),
    );

    await tester.pumpWidget(CbtApp(sessionController: session));
    // Lets SessionController.restore() (no stored token -> signedOut) resolve.
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Ujian'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Masuk'), findsOneWidget);
  });
}
