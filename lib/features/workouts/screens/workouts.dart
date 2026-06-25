import '/core/utils/exports.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import '/core/providers/user_provider.dart';
import '/core/providers/workout_provider.dart';
import '/data/models/exercise_model.dart';
import '/features/tracker/screens/workout_tracker.dart';

import '/core/widgets/custom_route.dart';
import '/features/workouts/screens/workout_level.dart';
import '/features/workouts/screens/workouts_widgets/man_workouts.dart';
import '/features/workouts/screens/workouts_widgets/startworkout.dart';
import '/features/workouts/screens/workouts_widgets/woman_workouts.dart';

class Workouts extends ConsumerStatefulWidget {
  const Workouts({super.key});

  @override
  ConsumerState<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends ConsumerState<Workouts> {
  final ValueNotifier<int> _updateState = ValueNotifier(0);

  @override
  void dispose() {
    _updateState.dispose();
    super.dispose();
  }

  List<Exercise> chestExercises = [];
  List<Exercise> backExercises = [];
  List<Exercise> shoulderExercises = [];
  List<Exercise> armExercises = [];
  List<Exercise> legsExercises = [];
  List<Exercise> absExercises = [];

  List<Exercise> chestExercises1 = [];
  List<Exercise> backExercises1 = [];
  List<Exercise> armExercises1 = [];
  List<Exercise> legsExercises1 = [];
  List<Exercise> absExercises1 = [];

  List<Exercise> chestExercises2 = [];
  List<Exercise> backExercises2 = [];
  List<Exercise> armExercises2 = [];
  List<Exercise> legsExercises2 = [];
  List<Exercise> absExercises2 = [];

  loadData() async {
    final jsonString = await rootBundle.loadString('assets/exercise.json');
    Map<String, dynamic> data = json.decode(jsonString);
    ExerciseData exerciseData = ExerciseData.fromJson(data);
    chestExercises = exerciseData.chest;
    backExercises = exerciseData.back;
    shoulderExercises = exerciseData.shoulders;
    armExercises = exerciseData.arms;
    legsExercises = exerciseData.legs;
    absExercises = exerciseData.abs;

    chestExercises1 = exerciseData.chest1;
    backExercises1 = exerciseData.back1;
    armExercises1 = exerciseData.arms1;
    legsExercises1 = exerciseData.legs1;
    absExercises1 = exerciseData.abs1;

    chestExercises2 = exerciseData.chest2;
    backExercises2 = exerciseData.back2;
    armExercises2 = exerciseData.arms2;
    legsExercises2 = exerciseData.legs2;
    absExercises2 = exerciseData.abs2;
    _updateState.value++;
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user != null) {
        ref
            .read(workoutProvider.notifier)
            .fetchWorkoutsIfNeeded(user.gender, user.level);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final user = ref.watch(userProvider);
    final workoutState = ref.watch(workoutProvider);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.instance.primary),
        ),
      );
    }

    String gender = user.gender;
    String level = user.level;

    if (workoutState.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.instance.primary),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                        return [
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              BuildContext context,
                              int index,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: SizedBox(
                                  height: 52,
                                  width: width,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(32.0),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          createRoute(
                                            WorkoutCalendarScreen(level: level),
                                          ),
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.track_changes),
                                            SizedBox(width: 6),
                                            Text('View Calendar'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }, childCount: 1),
                          ),
                        ];
                      },
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ValueListenableBuilder(
                      valueListenable: _updateState,
                      builder: (context, _, __) {
                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            SizedBox(height: 10),
                            BodyPart(
                              image: gender == 'Male'
                                  ? "assets/man/chest.jpg"
                                  : "assets/woman/chest.jpg",
                              muscle: 'Chest',
                              level: '$level:',
                              workoutList: level == 'Beginner'
                                  ? chestExercises
                                  : level == 'Intermediate'
                                  ? chestExercises1
                                  : chestExercises2,
                            ),
                            BodyPart(
                              image: gender == 'Male'
                                  ? "assets/man/back.jpg"
                                  : "assets/woman/back.jpg",
                              muscle: 'Back',
                              level: '$level:',
                              workoutList: level == 'Beginner'
                                  ? backExercises
                                  : level == 'Intermediate'
                                  ? backExercises1
                                  : backExercises2,
                            ),
                            BodyPart(
                              image: gender == 'Male'
                                  ? "assets/man/arms.jpg"
                                  : "assets/woman/arms.jpg",
                              muscle: 'Arms',
                              level: '$level:',
                              workoutList: level == 'Beginner'
                                  ? armExercises
                                  : level == 'Intermediate'
                                  ? armExercises1
                                  : armExercises2,
                            ),
                            BodyPart(
                              image: gender == 'Male'
                                  ? "assets/man/shoulder.jpg"
                                  : "assets/woman/shoulders.jpg",
                              muscle: 'Shoulders',
                              level: '$level:',
                              workoutList: shoulderExercises,
                            ),
                            BodyPart(
                              image: gender == 'Male'
                                  ? "assets/man/legs.jpg"
                                  : "assets/woman/legs.jpg",
                              muscle: 'Legs',
                              level: '$level:',
                              workoutList: level == 'Beginner'
                                  ? legsExercises
                                  : level == 'Intermediate'
                                  ? legsExercises1
                                  : legsExercises2,
                            ),
                            BodyPart(
                              image: gender == 'Male'
                                  ? "assets/man/abs.jpg"
                                  : "assets/woman/abs.jpg",
                              muscle: 'Abs',
                              level: '$level:',
                              workoutList: level == 'Beginner'
                                  ? absExercises
                                  : level == 'Intermediate'
                                  ? absExercises1
                                  : absExercises2,
                            ),
                            const SizedBox(height: 5),
                            gender == 'Male'
                                ? WorkoutLvlTilesM(
                                    ontap: () => Navigator.push(
                                      context,
                                      createRoute(
                                        ManWorkouts(
                                          chest: workoutState.chest,
                                          back: workoutState.back,
                                          arms: workoutState.arms,
                                          abs: workoutState.abs,
                                          shoulders: workoutState.shoulders,
                                          legs: workoutState.legs,
                                        ),
                                      ),
                                    ),
                                    levelname: level == 'Beginner'
                                        ? "BEGINNER: GYM"
                                        : level == 'Intermediate'
                                        ? "INTERMEDIATE: GYM"
                                        : "ADVANCED: GYM",
                                    level: "⭐",
                                  )
                                : WorkoutLvlTilesW(
                                    ontap: () => Navigator.push(
                                      context,
                                      createRoute(
                                        WomanWorkouts(
                                          chest: workoutState.chest,
                                          back: workoutState.back,
                                          arms: workoutState.arms,
                                          abs: workoutState.abs,
                                          shoulders: workoutState.shoulders,
                                          legs: workoutState.legs,
                                        ),
                                      ),
                                    ),
                                    levelname: level == 'Beginner'
                                        ? "BEGINNER: GYM"
                                        : level == 'Intermediate'
                                        ? "INTERMEDIATE: GYM"
                                        : "ADVANCED: GYM",
                                    level: "⭐",
                                  ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkoutCategory extends StatelessWidget {
  final String image;
  final VoidCallback ontap;
  const WorkoutCategory({super.key, required this.image, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Ink(
        height: 260,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: AppColors.instance.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A5160).withValues(alpha: 0.2),
              offset: const Offset(1.1, 1.1),
              blurRadius: 10.0,
            ),
          ],
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(fit: BoxFit.contain, image: AssetImage(image)),
        ),
      ),
    );
  }
}

class BodyPart extends StatelessWidget {
  final String image;
  final String muscle;
  final String level;
  final List<Exercise> workoutList;

  const BodyPart({
    super.key,
    required this.image,
    required this.muscle,
    required this.level,
    required this.workoutList,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            createRoute(
              StartWorkout(
                muscle: muscle,
                level: level,
                image: image,
                list: workoutList,
              ),
            ),
          );
        },
        child: Ink(
          height: 120,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: AppColors.instance.secondary,
            image: DecorationImage(fit: BoxFit.cover, image: AssetImage(image)),
            boxShadow: [AppColors.instance.shadow],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: Text(
                  '$level\n$muscle'.toUpperCase(),
                  textAlign: TextAlign.left,
                  style: AppTextStyles.instance.title.copyWith(
                    color: AppColors.instance.onSurfaceDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
