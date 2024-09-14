import 'package:flutter/material.dart';

class ExerciseTitle extends StatelessWidget {
  final String exerciseTitle;

  const ExerciseTitle({Key? key, required this.exerciseTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Text(
        exerciseTitle,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
