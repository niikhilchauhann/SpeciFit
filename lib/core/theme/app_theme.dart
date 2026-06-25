import '/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.instance.primary,
    primary: AppColors.instance.primary,
    secondary: AppColors.instance.secondary,
    surface: AppColors.instance.surface,
    onSurface: AppColors.instance.onSurface,
    onPrimary: AppColors.instance.onPrimary,
    onSecondary: AppColors.instance.onSecondary,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  primaryColor: AppColors.instance.primary,
  scaffoldBackgroundColor: AppColors.instance.background,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.instance.surface,
    centerTitle: true,
  ),
  fontFamily: 'Gilroy',
  cardColor: AppColors.instance.surface,
  secondaryHeaderColor: AppColors.instance.secondary,
  dialogTheme: DialogThemeData(backgroundColor: AppColors.instance.background),
  tabBarTheme: TabBarThemeData(indicatorColor: AppColors.instance.primary),
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.instance.primary,
    primary: AppColors.instance.primary,
    secondary: AppColors.instance.secondary,
    surface: AppColors.instance.surfaceDark,
    onSurface: AppColors.instance.onSurfaceDark,
    onPrimary: AppColors.instance.onPrimaryDark,
    onSecondary: AppColors.instance.onSecondaryDark,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  primaryColor: AppColors.instance.primary,
  scaffoldBackgroundColor: AppColors.instance.backgroundDark,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.instance.surfaceDark,
    centerTitle: true,
  ),
  fontFamily: 'Gilroy',
  cardColor: AppColors.instance.surfaceDark,
  secondaryHeaderColor: AppColors.instance.secondary,
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.instance.backgroundDark,
  ),
  tabBarTheme: TabBarThemeData(indicatorColor: AppColors.instance.primary),
);
