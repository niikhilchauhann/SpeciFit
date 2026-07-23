import 'package:flutter/material.dart';

class AppColors {
  AppColors._shared();
  static final AppColors instance = AppColors._shared();

  final Color primary = const Color(0xff125ce1);
  final Color secondary = const Color(0xffD6E5FC);
  final Color blue = const Color(0xff0156F0);

  final Color background = const Color(0xFFFAFAFA);
  final Color surface = const Color(0xfff1f1f1);

  final Color backgroundDark = const Color(0xFF121212);
  final Color surfaceDark = const Color(0xff1e1e1e);

  final Color onBackground = Colors.black87;
  final Color onSurface = Colors.black87;

  final Color onBackgroundDark = const Color(0xFFE0E0E0);
  final Color onSurfaceDark = const Color(0xFFFAFAFA);

  final Color onPrimary = Colors.white;
  final Color onSecondary = Colors.white;

  final Color onPrimaryDark = Colors.black87;
  final Color onSecondaryDark = Colors.black87;

  final Color stepsColor = const Color(0xFFf05859);
  final Color caloriesColor = const Color(0xfff1a057);
  final Color statsColor = const Color(0xff5571f0);
  final Color waterColor = const Color(0xFF4BBEE1);
  final Color carbsColor = const Color(0xFF87A0E5);
  final Color proteinColor = const Color(0xFFF56E98);
  final Color fatColor = Colors.amber.shade400;

  final BoxShadow shadow = BoxShadow(
    color: const Color(0xFF3A5160).withValues(alpha: 0.5),
    offset: const Offset(1.1, 1.1),
    blurRadius: 10,
  );
}
