import 'package:flutter/material.dart';

import '../models/exam_models.dart';
import '../state/session_controller.dart';
import '../theme/app_palette.dart';
import '../widgets/responsive.dart';
import '../widgets/shell_body.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'materi_screen.dart';
import 'profile_screen.dart';

/// Hosts the persistent nav rail + header around the four primary tabs.
/// Login and the locked exam session live outside this shell on purpose.
///
/// Fetches `/dashboard` once here (rather than per-tab) since Dashboard and
/// History both need it and `IndexedStack` keeps both alive for the shell's
/// lifetime anyway.
class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  DashboardData? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await SessionScope.of(context).examService.fetchDashboard();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data. Periksa koneksi lalu coba lagi.';
        _loading = false;
      });
    }
  }

  void _selectTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.paper,
      body: SafeArea(
        child: ShellBody(
          selectedIndex: _index,
          onSelect: _selectTab,
          child: IndexedStack(
            index: _index,
            children: [
              DashboardScreen(
                loading: _loading,
                error: _error,
                exams: _data?.exams ?? const [],
                onRefresh: _load,
              ),
              const MateriScreen(),
              HistoryScreen(
                loading: _loading,
                error: _error,
                history: _data?.history ?? const [],
                onRefresh: _load,
              ),
              const ProfileScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isWideLayout(context)
          ? null
          : ShellBottomNav(selectedIndex: _index, onSelect: _selectTab),
    );
  }
}
