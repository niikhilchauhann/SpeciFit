import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/providers/user_provider.dart';

class GoalWeightNotifier extends Notifier<double> {
  bool _isDefaultSet = false;
  double _currentGoal = 0.0;

  @override
  double build() {
    final user = ref.watch(userProvider);
    
    if (user != null && !_isDefaultSet) {
      _isDefaultSet = true;
      final lowerGoal = user.goal.toLowerCase();
      if (lowerGoal.contains('lose')) {
        _currentGoal = user.weight - 5.0;
      } else if (lowerGoal.contains('gain')) {
        _currentGoal = user.weight + 5.0;
      } else {
        _currentGoal = user.weight.toDouble();
      }
    }
    
    if (user != null && _currentGoal == 0.0) {
      _currentGoal = user.weight.toDouble();
    }
    
    return _currentGoal;
  }
  
  void updateWeight(double newGoal) {
    _currentGoal = newGoal;
    _isDefaultSet = true;
    state = newGoal;
  }
}

final goalWeightProvider = NotifierProvider<GoalWeightNotifier, double>(() {
  return GoalWeightNotifier();
});
