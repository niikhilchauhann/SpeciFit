import 'package:flutter/material.dart';

import '../../utilities/export.dart';

class WaterButton extends StatelessWidget {
  final VoidCallback ontap;
  final dynamic icon;
  const WaterButton({super.key, required this.ontap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: bgcolor,
          ),
        ),
      ),
    );
  }
}
