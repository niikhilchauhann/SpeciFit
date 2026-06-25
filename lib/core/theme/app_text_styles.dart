import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._shared();
  static final AppTextStyles instance = AppTextStyles._shared();

  final TextStyle headlineLarge = const TextStyle(
    fontFamily: 'Gilroy',
    fontWeight: FontWeight.w600,
    fontSize: 42,
  );

  final TextStyle headline = const TextStyle(
    fontFamily: 'Gilroy',
    fontWeight: FontWeight.w600,
    fontSize: 36,
  );

  final TextStyle headlineSmall = const TextStyle(
    fontFamily: 'Gilroy',
    fontWeight: FontWeight.w600,
    fontSize: 24,
  );

  final TextStyle titleLarge = const TextStyle(
    fontFamily: 'Gilroy',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    letterSpacing: 0.5,
  );

  final TextStyle title = const TextStyle(
    fontFamily: 'Gilroy',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.5,
  );

  final TextStyle titleSmall = const TextStyle(
    fontFamily: 'Gilroy',
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.5,
  );

  final TextStyle bodyLarge = const TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  final TextStyle body = const TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  final TextStyle bodySmall = const TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  final TextStyle labelLarge = const TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 14,
  );

  final TextStyle label = const TextStyle(fontFamily: 'Gilroy', fontSize: 12);

  final TextStyle labelSmall = const TextStyle(
    fontFamily: 'Gilroy',
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
}
