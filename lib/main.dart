import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'services/update_service.dart';
import 'state/session_controller.dart';
import 'state/theme_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/update_sheet.dart';

void main() {
  runApp(const CbtApp());
}

class CbtApp extends StatefulWidget {
  const CbtApp({super.key});

  @override
  State<CbtApp> createState() => _CbtAppState();
}

class _CbtAppState extends State<CbtApp> {
  final _themeController = ThemeController();
  final _sessionController = SessionController();
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
              home: const LoginScreen(),
            );
          },
        ),
      ),
    );
  }
}
