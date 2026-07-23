import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/data/adapters/workout_adapter.dart';
import '/data/models/exercise_model.dart';

import '/core/widgets/custom_route.dart';
import '/features/workouts/screens/exercise_tile.dart';
import '/features/workouts/screens/workouts_widgets/workout_steps.dart';

class StartWorkout extends StatefulWidget {
  final String muscle;
  final String level;
  final String image;
  final List<Exercise> list;
  const StartWorkout({
    super.key,
    required this.muscle,
    required this.level,
    required this.image,
    required this.list,
  });

  @override
  State<StartWorkout> createState() => _StartWorkoutState();
}

class _StartWorkoutState extends State<StartWorkout> {
  Box<Workout> workoutBox = Hive.box<Workout>('workouts');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(widget.image),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(widget.muscle, style: AppTextStyles.instance.titleLarge),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: widget.list.length,
              itemBuilder: (context, index) {
                return ExerciseTile(
                  bodyPart: widget.list[index].bodyPart,
                  equipment: widget.list[index].equipment,
                  gifUrl: widget.list[index].gifUrl,
                  name: widget.list[index].name,
                  target: widget.list[index].target,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                Navigator.push(
                  context,
                  createRoute(
                    WorkoutSteps(
                      exerciseName: widget.muscle,
                      workoutBox: workoutBox,
                      workoutList: widget.list,
                    ),
                  ),
                );
              },
              child: Ink(
                width: MediaQuery.of(context).size.width - 80,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: AppColors.instance.primary,
                  boxShadow: kElevationToShadow[3],
                ),
                child: Text(
                  "Start Workout",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.instance.title.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
