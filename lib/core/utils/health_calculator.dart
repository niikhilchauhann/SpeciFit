import '/data/models/users_model.dart';

class HealthCalculator {
  static double calculateBMR(Users user, double weight) {
    if (user.gender.toLowerCase() == 'male') {
      return 10 * weight + 6.25 * user.height - 5 * user.age + 5;
    } else {
      return 10 * weight + 6.25 * user.height - 5 * user.age - 161;
    }
  }

  static double calculateTDEE(double bmr, String lifestyle) {
    switch (lifestyle) {
      case 'Sedentary':
        return bmr * 1.2;
      case 'Lightly active':
        return bmr * 1.375;
      case 'Moderately active':
        return bmr * 1.55;
      case 'Very active':
        return bmr * 1.725;
      case 'Extremely active':
        return bmr * 1.9;
      default:
        return bmr * 1.55;
    }
  }

  static double calculateTargetCalories(double tdee, String goal) {
    final baseGoal = goal.toLowerCase().split(' ').first;
    switch (baseGoal) {
      case 'lose':
        return tdee - 500;
      case 'gain':
        return tdee + 500;
      case 'maintain':
      default:
        return tdee;
    }
  }

  static Map<String, double> calculateMacros(double calories) {
    return {
      'protein': (calories * 0.20) / 4,
      'carbs': (calories * 0.55) / 4,
      'fat': (calories * 0.25) / 9,
    };
  }
}
