import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// The "S" brand mark used on the login card and top of the nav rail.
class AppMark extends StatelessWidget {
  final double size;

  const AppMark({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.accent,
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      child: Text(
        'S',
        style: TextStyle(
          color: p.accentOn,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
