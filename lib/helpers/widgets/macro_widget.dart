import 'package:flutter/material.dart';

class MacroWidget extends StatelessWidget {
  const MacroWidget({
    super.key,
    required this.macro,
    required this.macrocolor,
    required this.macroname,
  });

  final dynamic macro;
  final String macroname;
  final dynamic macrocolor;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          height: 36,
          width: 5,
          decoration: BoxDecoration(
              color: macrocolor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(macro, style: theme.titleSmall),
            Text(macroname, style: theme.labelLarge),
          ],
        ),
      ],
    );
  }
}
