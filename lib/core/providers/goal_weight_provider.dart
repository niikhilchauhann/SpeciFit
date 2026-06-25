import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalWeightNotifier extends Notifier<double> {
  @override
  double build() {
    return 75.0;
  }
  
  void updateWeight(double newGoal) {
    state = newGoal;
  }
}

final goalWeightProvider = NotifierProvider<GoalWeightNotifier, double>(() {
  return GoalWeightNotifier();
});
