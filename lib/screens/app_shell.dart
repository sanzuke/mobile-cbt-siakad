import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../widgets/nav_rail.dart';
import '../widgets/shell_header.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'materi_screen.dart';
import 'profile_screen.dart';

/// Hosts the persistent nav rail + header around the four primary tabs.
/// Login and the locked exam session live outside this shell on purpose.
class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.paper,
      body: SafeArea(
        child: Row(
          children: [
            NavRail(selectedIndex: _index, onSelect: (i) => setState(() => _index = i)),
            Container(width: 1, color: p.line),
            Expanded(
              child: Column(
                children: [
                  const ShellHeader(),
                  Expanded(
                    child: IndexedStack(
                      index: _index,
                      children: const [
                        DashboardScreen(),
                        MateriScreen(),
                        HistoryScreen(),
                        ProfileScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
