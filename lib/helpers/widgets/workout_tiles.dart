import 'package:flutter/cupertino.dart';
import 'package:specifit/utilities/export.dart';
import '../../screens/details/workout_details.dart';

class WorkoutTiles extends StatelessWidget {
  final List list;
  const WorkoutTiles({
    super.key,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(22, 0, 0, 0),
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: ((context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                createRoute(
                  WorkoutDetails(
                    category: list[index].eCategory,
                    howTo: list[index].eHowTo,
                    howToVideo: list[index].eHowToVideo,
                    image: list[index].eImage,
                    kcal: list[index].eKcal,
                    name: list[index].eName,
                    target: list[index].eTarget,
                  ),
                ),
              );
            },
            child: ExerciseCard(
              exerciseImage: list[index].eImage,
              exerciseName: list[index].eName,
            ),
          );
        }),
      ),
    );
  }
}
