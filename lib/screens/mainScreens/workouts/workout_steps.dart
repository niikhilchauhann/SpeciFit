import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:specifit/utilities/export.dart';

import '../../../helpers/adapters/workout_adapter.dart';
import '../../../helpers/models/exercise_model.dart';

class WorkoutSteps extends StatefulWidget {
  final String exerciseName;
  final Box<Workout> workoutBox;
  final List<Exercise> workoutList;
  const WorkoutSteps(
      {super.key,
      required this.exerciseName,
      required this.workoutBox,
      required this.workoutList});

  @override
  State<WorkoutSteps> createState() => _WorkoutStepsState();
}

class _WorkoutStepsState extends State<WorkoutSteps> {
  Box<Workout> workoutBox = Hive.box<Workout>('workouts');
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentStep = _pageController.page!.round();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startWorkout();
    });
  }

  final _stopwatch = Stopwatch();
  bool isWorkingOut = false;
  void _startWorkout() {
    _stopwatch.start();
    setState(() {
      isWorkingOut = true;
    });
    // if (kDebugMode) {
    //   print("Workout Started");
    // }
  }

  void _endWorkout() async {
    _stopwatch.stop();
    final workout = Workout(
      date: DateTime.now().toUtc(),
      timeSpent: _stopwatch.elapsed.inSeconds,
    );
    await widget.workoutBox.add(workout);
    _stopwatch.reset();
    setState(() {
      isWorkingOut = false;
    });
    // if (kDebugMode) {
    //   print("Workout Ended");
    // }
  }

  onExit() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: "Are you sure you want to exit?",
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      btnOkOnPress: () {
        _endWorkout();
        Navigator.pop(context);
      },
      btnCancelOnPress: () {},
    ).show();
  }

  final _pageController = PageController(initialPage: 0);
  int currentStep = 0;
  bool get isLastPage => currentStep == widget.workoutList.length - 1;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;

    animateToNext() {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    }

    animateToPrevious() {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    }

    return WillPopScope(
        onWillPop: () async {
          onExit();
          return Future.value(false);
        },
        child: Scaffold(
            body: SafeArea(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
              Row(children: [
                IconButton(
                    onPressed: () {
                      animateToPrevious();
                    },
                    icon:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                const SizedBox(width: 5),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (currentStep + 1) / widget.workoutList.length,
                    backgroundColor: Theme.of(context).colorScheme.outline,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      primary,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                    onPressed: onExit, icon: const Icon(Icons.close_rounded))
              ]),
              const SizedBox(height: 20),
              Expanded(
                  child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.workoutList.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.2,
                              child: Text(
                                widget.workoutList[index].name,
                                style: Theme.of(context).textTheme.displaySmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: CachedNetworkImage(
                                imageUrl: (widget.workoutList[index].gifUrl),
                              ),
                            ),
                            Text(
                              '12 repitions\nx 4 sets',
                              style: Theme.of(context).textTheme.displaySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      })),
              const SizedBox(height: 35),
              InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () {
                  if (isLastPage == false) {
                    animateToNext();
                  } else {
                    if (isWorkingOut) {
                      showCupertinoModalPopup(
                          barrierColor: Colors.black87,
                          context: context,
                          builder: (context) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Workout Finished",
                                      style: theme.titleMedium,
                                    ),
                                    Text(
                                        _stopwatch.elapsed
                                            .toString()
                                            .split('.')
                                            .first,
                                        style: theme.titleMedium),
                                    const SizedBox(height: 5),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OKAY'))
                                  ])).then((value) {
                        _endWorkout();
                      });
                    } else {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Ink(
                  width: MediaQuery.of(context).size.width - 80,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: primary,
                      boxShadow: kElevationToShadow[3]),
                  child: Text(isLastPage ? "FINISH WORKOUT" : "NEXT",
                      textAlign: TextAlign.center, style: theme.titleMedium),
                ),
              ),
              const SizedBox(height: 30)
            ]))));
  }
}
