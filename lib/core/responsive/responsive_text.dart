import 'package:flutter/material.dart';

import '/core/responsive/responsive.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize = style.fontSize ?? 13;
    double scaledFontSize = Res.scaleFontSize(context, fontSize);

    return Text(
      text,
      style: style.copyWith(fontSize: scaledFontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
