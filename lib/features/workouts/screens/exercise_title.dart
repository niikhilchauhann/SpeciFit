import '/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class ExerciseTitle extends StatelessWidget {
  final String exerciseTitle;

  const ExerciseTitle({super.key, required this.exerciseTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Text(exerciseTitle, style: AppTextStyles.instance.titleLarge),
    );
  }
}
