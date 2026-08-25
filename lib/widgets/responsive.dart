import 'package:flutter/material.dart';

/// Below this width the app is treated as a phone (single-column, bottom
/// nav bar); at or above it, as a tablet (persistent side [NavRail]).
/// 640dp comfortably separates phones (~360-430dp portrait, up to ~600dp
/// landscape on small phones) from 7"+ tablets.
const double kTabletBreakpoint = 640;

bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kTabletBreakpoint;
