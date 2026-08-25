import 'package:flutter/material.dart';

/// Holds the user's chosen display mode (Terang / Gelap / Otomatis).
class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void toggle(Brightness currentEffective) {
    setMode(currentEffective == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

/// Makes [ThemeController] reachable from anywhere below it without an
/// external state-management package.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope not found in context');
    return scope!.notifier!;
  }
}
