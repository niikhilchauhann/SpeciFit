import 'package:flutter/material.dart';

import '../../utilities/export.dart';

class WorkoutLvlTilesM extends StatelessWidget {
  final VoidCallback ontap;
  final String levelname;
  final String level;

  const WorkoutLvlTilesM({
    Key? key,
    required this.ontap,
    required this.levelname,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: ontap,
      child: Ink(
        height: 195,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          image: const DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(
              "assets/man/man.jpg",
            ),
          ),
          boxShadow: [shadow],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              right: 20,
              child: Text(
                levelname,
                textAlign: TextAlign.center,
                style: h2white,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(
                level,
                style: h3white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class WorkoutLvlTilesW extends StatelessWidget {
  final VoidCallback ontap;
  final String levelname;
  final String level;

  const WorkoutLvlTilesW({
    Key? key,
    required this.ontap,
    required this.levelname,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: ontap,
      child: Ink(
        height: 195,
        decoration: BoxDecoration(
            image: const DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/woman/women.jpg"),
            ),
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.secondary),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                levelname,
                textAlign: TextAlign.center,
                style: h2white,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(
                level,
                style: h3white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
