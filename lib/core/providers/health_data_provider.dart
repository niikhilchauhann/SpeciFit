import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/services/health_service.dart';

class HealthDataState {
  final int steps;
  final double sleepHours;
  final List<double> weeklySleep;

  HealthDataState({
    required this.steps,
    required this.sleepHours,
    required this.weeklySleep,
  });
}

final healthDataProvider = FutureProvider.family<HealthDataState, DateTime>((
  ref,
  selectedDate,
) async {
  int steps = await HealthService().getSteps(selectedDate);
  double sleep = await HealthService().getSleepHours(selectedDate);

  List<double> weeklySleep = [];
  for (int i = 6; i >= 0; i--) {
    DateTime day = selectedDate.subtract(Duration(days: i));
    double dailySleep = await HealthService().getSleepHours(day);
    weeklySleep.add(dailySleep);
  }

  return HealthDataState(
    steps: steps,
    sleepHours: sleep,
    weeklySleep: weeklySleep,
  );
});
