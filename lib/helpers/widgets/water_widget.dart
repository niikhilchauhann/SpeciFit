import 'package:flutter/material.dart';

class WaterDrinkWidget extends StatelessWidget {
  const WaterDrinkWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD7E0F9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: kElevationToShadow[3],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 68, bottom: 12, right: 16, top: 12),
                    child: Text(
                      'Prepare your stomach for lunch with one or two glass of water',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        letterSpacing: 0.0,
                        color: const Color(0xFF2633C5).withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -12,
            left: 0,
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.asset("assets/fitness_app/glass.png"),
            ),
          )
        ],
      ),
    );
  }
}
