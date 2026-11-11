import 'package:flutter/material.dart';

/// Shared layout and shape tokens used across the mobile experience.
class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double pill = 999;
}

class AppElevation {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A0D1014),
      blurRadius: 16,
      offset: Offset(0, 5),
    ),
  ];
}
