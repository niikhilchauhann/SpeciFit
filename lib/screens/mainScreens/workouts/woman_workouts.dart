import 'package:flutter/material.dart';

import 'package:specifit/utilities/export.dart';

class WomanWorkouts extends StatefulWidget {
  final List chest;
  final List back;
  final List arms;
  final List abs;
  final List shoulders;
  final List legs;
  const WomanWorkouts(
      {super.key,
      required this.chest,
      required this.back,
      required this.arms,
      required this.abs,
      required this.shoulders,
      required this.legs});

  @override
  State<WomanWorkouts> createState() => _WomanWorkoutsState();
}

class _WomanWorkoutsState extends State<WomanWorkouts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Woman",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text("These workouts will help you get:",
                style: Theme.of(context).textTheme.bodySmall),
          ),
          const ExerciseTitle(exerciseTitle: 'Round Booty'),
          WorkoutTiles(list: widget.legs),
          const ExerciseTitle(exerciseTitle: 'Bigger Breasts'),
          WorkoutTiles(list: widget.chest),
          const ExerciseTitle(exerciseTitle: 'Flat Belly'),
          WorkoutTiles(list: widget.abs),
          const ExerciseTitle(exerciseTitle: 'Wider Back'),
          WorkoutTiles(list: widget.back),
          const ExerciseTitle(exerciseTitle: 'Toned Arms'),
          WorkoutTiles(list: widget.arms),
          const ExerciseTitle(exerciseTitle: 'Strong Shoulders'),
          WorkoutTiles(list: widget.shoulders),
          const SizedBox(height: 30)
        ],
      ),
    );
  }
}
