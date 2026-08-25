import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import 'nav_rail.dart';
import 'responsive.dart';
import 'shell_header.dart';

/// Composes [ShellHeader] + tab content with the width-appropriate
/// navigation chrome: a persistent left [NavRail] on tablets, nothing here
/// on phones (pair with [ShellBottomNav] as the phone's Scaffold
/// bottomNavigationBar instead — a side rail would eat too much width on a
/// phone-sized screen).
class ShellBody extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Widget child;

  const ShellBody({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final content = Column(
      children: [
        const ShellHeader(),
        Expanded(child: child),
      ],
    );

    if (!isWideLayout(context)) return content;

    return Row(
      children: [
        NavRail(selectedIndex: selectedIndex, onSelect: onSelect),
        Container(width: 1, color: p.line),
        Expanded(child: content),
      ],
    );
  }
}

/// Phone-only bottom tab bar mirroring [NavRail]'s four destinations.
/// `selectedIndex < 0` (pushed screens like PreExam that aren't one of the
/// four tabs) renders with nothing highlighted.
class ShellBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const ShellBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: onSelect,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Beranda',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Materi',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'Riwayat',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
