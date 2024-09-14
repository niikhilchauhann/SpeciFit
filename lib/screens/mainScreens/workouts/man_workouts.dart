import 'package:flutter/material.dart';

import 'package:specifit/utilities/export.dart';

class ManWorkouts extends StatefulWidget {
  final List chest;
  final List back;
  final List arms;
  final List abs;
  final List shoulders;
  final List legs;
  const ManWorkouts(
      {super.key,
      required this.chest,
      required this.back,
      required this.arms,
      required this.abs,
      required this.shoulders,
      required this.legs});

  @override
  State<ManWorkouts> createState() => _ManWorkoutsState();
}

class _ManWorkoutsState extends State<ManWorkouts> {
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
          "Man",
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
          const ExerciseTitle(exerciseTitle: 'Bigger Chest'),
          WorkoutTiles(list: widget.chest),
          const ExerciseTitle(exerciseTitle: 'Wider Back'),
          WorkoutTiles(list: widget.back),
          const ExerciseTitle(exerciseTitle: 'Strong Arms'),
          WorkoutTiles(list: widget.arms),
          const ExerciseTitle(exerciseTitle: 'Round Shoulders'),
          WorkoutTiles(list: widget.shoulders),
          const ExerciseTitle(exerciseTitle: '6-Pack Abs'),
          WorkoutTiles(list: widget.abs),
          const ExerciseTitle(exerciseTitle: 'Chicken Legs'),
          WorkoutTiles(list: widget.legs),
          const SizedBox(height: 30)
        ],
      ),
    );
  }
}
