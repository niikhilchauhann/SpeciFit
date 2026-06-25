import 'package:flutter/material.dart';

import '/core/responsive/responsive.dart';

class Space {
  static SizedBox s4(BuildContext context) =>
      SizedBox(height: Res.scaleSpacing(context, 4.0));
  static SizedBox s6(BuildContext context) =>
      SizedBox(height: Res.scaleSpacing(context, 6.0));
  static SizedBox s8(BuildContext context) =>
      SizedBox(height: Res.scaleSpacing(context, 8.0));
  static SizedBox s12(BuildContext context) =>
      SizedBox(height: Res.scaleSpacing(context, 12.0));
  static SizedBox s16(BuildContext context) =>
      SizedBox(height: Res.scaleSpacing(context, 16.0));
  static SizedBox s20(BuildContext context) =>
      SizedBox(height: Res.scaleSpacing(context, 20.0));
  static SizedBox s24(BuildContext context) =>
      SizedBox(height: Res.scaleSpacing(context, 24.0));

  static SizedBox w4(BuildContext context) =>
      SizedBox(width: Res.scaleSpacing(context, 4.0));
  static SizedBox w6(BuildContext context) =>
      SizedBox(width: Res.scaleSpacing(context, 6.0));
  static SizedBox w8(BuildContext context) =>
      SizedBox(width: Res.scaleSpacing(context, 8.0));
  static SizedBox w12(BuildContext context) =>
      SizedBox(width: Res.scaleSpacing(context, 12.0));
  static SizedBox w16(BuildContext context) =>
      SizedBox(width: Res.scaleSpacing(context, 16.0));

  static double ro(BuildContext context) => Res.scaleSpacing(context, 14.0);
  static double ri(BuildContext context) => Res.scaleSpacing(context, 10.0);
  static double pdo(BuildContext context) => Res.scaleSpacing(context, 20.0);
  static double pdi(BuildContext context) => Res.scaleSpacing(context, 16.0);
}
