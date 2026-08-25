import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import 'app_mark.dart';

/// Left-side navigation rail — the tablet-appropriate pattern (vs. a
/// bottom tab bar on phones, see [ShellBottomNav] in `shell_body.dart`).
/// Shown only at [kTabletBreakpoint] and above (see [ShellBody]).
/// Deliberately absent on Login and the locked exam session screen.
class NavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const NavRail({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 78,
      color: p.surfaceVariant,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const AppMark(size: 34),
          const SizedBox(height: 14),
          _RailItem(
            icon: Icons.home_outlined,
            label: 'Beranda',
            selected: selectedIndex == 0,
            onTap: () => onSelect(0),
          ),
          _RailItem(
            icon: Icons.menu_book_outlined,
            label: 'Materi',
            badge: 'Segera',
            selected: selectedIndex == 1,
            onTap: () => onSelect(1),
          ),
          _RailItem(
            icon: Icons.history,
            label: 'Riwayat',
            selected: selectedIndex == 2,
            onTap: () => onSelect(2),
          ),
          const Spacer(),
          _RailItem(
            icon: Icons.person_outline,
            label: 'Profil',
            selected: selectedIndex == 3,
            onTap: () => onSelect(3),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? p.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: selected ? p.accent : p.inkFaint,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: selected ? p.accent : p.inkFaint,
                        ),
                      ),
                    ],
                  ),
                  if (badge != null)
                    Positioned(
                      top: -2,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: p.amber,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: p.surface,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
