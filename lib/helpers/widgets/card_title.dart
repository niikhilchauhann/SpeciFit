import 'package:flutter/material.dart';

import '../../utilities/export.dart';

class CardTitle extends StatelessWidget {
  final String title;
  final dynamic icon;
  final double size;

  const CardTitle(
      {super.key, required this.title, required this.icon, this.size = 22});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: bgcolor,
            size: size,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: h2white,
        ),
      ],
    );
  }
}
