import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:elegant_notification/resources/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../helpers/adapters/workout_adapter.dart';
import '../../utilities/export.dart';

class WorkoutCalendarScreen extends StatefulWidget {
  final String level;
  const WorkoutCalendarScreen({super.key, required this.level});

  @override
  State<WorkoutCalendarScreen> createState() => _WorkoutCalendarScreenState();
}

class _WorkoutCalendarScreenState extends State<WorkoutCalendarScreen> {
  late DateTime _selectedDate;
  late int _workoutCount;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _workoutCount = _getWorkoutCount(_selectedDate);
  }

  final workoutsBox = Hive.box<Workout>('workouts');
  final workoutTimeByDate = <DateTime, int>{};
  Widget _buildCalendar() {
    for (final workout in workoutsBox.values) {
      final date = workout.date;
      final timeSpent = workout.timeSpent;
      if (workoutTimeByDate.containsKey(date)) {
        workoutTimeByDate[date] = workoutTimeByDate[date]! + timeSpent;
      } else {
        workoutTimeByDate[date] = timeSpent;
      }
    }

    return Material(
      textStyle: Theme.of(context).textTheme.titleMedium,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border:
                Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(20),
            boxShadow: kElevationToShadow[3]),
        child: HeatMapCalendar(
            datasets: workoutTimeByDate,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            borderRadius: 50,
            colorMode: ColorMode.color,
            defaultColor: Theme.of(context).colorScheme.outlineVariant,
            textColor: Colors.white,
            showColorTip: false,
            flexible: true,
            monthFontSize: 15,
            size: 36,
            colorsets: const {
              0: Color(0xFFFF6461),
              600: Color(0xFFFF9800),
              1800: Color(0xFFFFEB3B),
              2700: Color(0xFF33CC33),
              3600: Color(0xFF008004),
            },
            onClick: (value) => _onDaySelected(value, value)),
      ),
    );
  }

  int _getWorkoutCount(DateTime selectedDate) {
    int count = 0;
    for (var i = 0; i < workoutsBox.length; i++) {
      final workout = workoutsBox.getAt(i)!;
      if (workout.date.year == selectedDate.year &&
          workout.date.month == selectedDate.month &&
          workout.date.day == selectedDate.day) {
        count++;
      }
    }
    return count;
  }

  Box<Workout> workoutBox = Hive.box<Workout>('workouts');
  void _endWorkout() async {
    final workout = Workout(
      date: DateTime.now().toUtc(),
      timeSpent: 3600,
    );
    await workoutBox.add(workout);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final workoutsForSelectedDay = workoutsBox.values
        .where((workout) => isSameDay(workout.date, _selectedDate))
        .toList();
    final totalDuration = workoutsForSelectedDay.fold(
        0, (sum, workout) => sum + workout.timeSpent);
    var weight = 60;
    var levelMET = widget.level;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text("Workout Tracker")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(.3)),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text('Showing data for the date:', style: theme.bodySmall),
                SizedBox(
                    width: 150,
                    child: Text(DateFormat.yMMMEd().format(_selectedDate),
                        style: const TextStyle(
                            fontSize: 14,
                            wordSpacing: 1,
                            fontWeight: FontWeight.w600))),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MacroWidget(
                        macro:
                            '${(totalDuration ~/ 60).toString().padLeft(2, '0')}:${(totalDuration % 60).toString().padLeft(2, '0')} min',
                        macroname: "Total Time",
                        macrocolor: inforColor),
                    MacroWidget(
                        macro: _workoutCount.toString(),
                        macroname: "Workouts",
                        macrocolor: caloriescolor),
                    MacroWidget(
                        macro: ((totalDuration / 60) *
                                ((levelMET == 'Beginner'
                                        ? 4
                                        : levelMET == 'Intermediate'
                                            ? 5
                                            : levelMET == 'Advanced'
                                                ? 6
                                                : 10) *
                                    3.5 *
                                    weight) /
                                200)
                            .toStringAsFixed(0),
                        macroname: "Calories",
                        macrocolor: errorColor),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Workout Heatmap', style: theme.titleMedium),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCalendar(),
          Expanded(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CupertinoButton.filled(
                      onPressed: () {
                        _endWorkout();
                        setState(() {
                          _selectedDate = DateTime.now();
                        });
                        ElegantNotification.success(
                                animation: AnimationType.fromBottom,
                                title: const Text("Workout Added",
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.w600)),
                                description: const Text(
                                    "We have added 1 hour to your workout duration!",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(color: color, fontSize: 12)))
                            .show(context);
                      },
                      child: const Text("I worked out at gym today!",
                          style: h3white)))),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _workoutCount = _getWorkoutCount(selectedDay);
    });
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
