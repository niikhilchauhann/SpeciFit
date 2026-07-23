import 'package:flutter/material.dart';

class Res {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= 640;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > 640 &&
      MediaQuery.of(context).size.width <= 1080;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1080;

  static double getScalingFactor(BuildContext context) {
    if (isMobile(context)) return 0.92;
    // if (isTablet(context)) return 1.05;
    // if (isDesktop(context)) return 1;
    return 1.05;
  }

  static double scaleFontSize(BuildContext context, double fontSize) {
    double scaleFactor = getScalingFactor(context);
    return fontSize * scaleFactor;
  }

  // Get scaling factor for padding and spacing
  static double getSpacingScalingFactor(BuildContext context) {
    if (isMobile(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.2;
    } else if (isDesktop(context)) {
      return 1.4;
    }
    return 1.0;
  }

  // Scale padding and spacing based on device type
  static double scaleSpacing(BuildContext context, double spacing) {
    double scaleFactor = getSpacingScalingFactor(context);
    return spacing * scaleFactor;
  }
}
