import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'screens/login_screen.dart';
import 'services/update_service.dart';
import 'state/session_controller.dart';
import 'state/theme_controller.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';
import 'widgets/update_sheet.dart';

void main() {
  runApp(const CbtApp());
}

class CbtApp extends StatefulWidget {
  /// Overridable for tests, so widget tests don't have to go through the
  /// real [SessionController] (which touches platform secure storage —
  /// see `test/widget_test.dart` for why that matters).
  final SessionController? sessionController;

  const CbtApp({super.key, this.sessionController});

  @override
  State<CbtApp> createState() => _CbtAppState();
}

class _CbtAppState extends State<CbtApp> {
  final _themeController = ThemeController();
  late final SessionController _sessionController =
      widget.sessionController ?? SessionController();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    _sessionController.restore();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    final info = await _updateService.checkForUpdate();
    if (info == null || !info.updateAvailable) return;

    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    await UpdateSheet.show(context, info: info, mandatory: info.isMandatory);
  }

  @override
  void dispose() {
    _themeController.dispose();
    _sessionController.dispose();
    _updateService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      controller: _sessionController,
      child: ThemeScope(
        controller: _themeController,
        child: AnimatedBuilder(
          animation: _themeController,
          builder: (context, _) {
            return MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'CBT SIAKAD',
              debugShowCheckedModeBanner: false,
              themeMode: _themeController.mode,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              home: const _SessionGate(),
            );
          },
        ),
      ),
    );
  }
}

/// Routes to [AppShell] or [LoginScreen] once [SessionController.restore]
/// resolves, showing a brief loading state while a stored token is being
/// re-validated against `/me`.
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        return switch (session.status) {
          SessionStatus.unknown => Scaffold(
              backgroundColor: context.palette.paper,
              body: const Center(child: CircularProgressIndicator()),
            ),
          SessionStatus.signedIn => const AppShell(),
          SessionStatus.signedOut => const LoginScreen(),
        };
      },
    );
  }
}
