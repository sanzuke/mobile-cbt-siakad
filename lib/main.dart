import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'state/theme_controller.dart';
import 'theme/app_theme.dart';

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

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'CBT SIAKAD',
            debugShowCheckedModeBanner: false,
            themeMode: _themeController.mode,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
