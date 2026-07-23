import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/data/repositories/workout_repository.dart';
import '/data/models/gym_workout_model.dart';

class WorkoutState {
  final bool isLoading;
  final String? currentGender;
  final String? currentLevel;
  final List<GymWorkoutModel> chest;
  final List<GymWorkoutModel> back;
  final List<GymWorkoutModel> arms;
  final List<GymWorkoutModel> shoulders;
  final List<GymWorkoutModel> abs;
  final List<GymWorkoutModel> legs;

  WorkoutState({
    this.isLoading = false,
    this.currentGender,
    this.currentLevel,
    this.chest = const [],
    this.back = const [],
    this.arms = const [],
    this.shoulders = const [],
    this.abs = const [],
    this.legs = const [],
  });

  WorkoutState copyWith({
    bool? isLoading,
    String? currentGender,
    String? currentLevel,
    List<GymWorkoutModel>? chest,
    List<GymWorkoutModel>? back,
    List<GymWorkoutModel>? arms,
    List<GymWorkoutModel>? shoulders,
    List<GymWorkoutModel>? abs,
    List<GymWorkoutModel>? legs,
  }) {
    return WorkoutState(
      isLoading: isLoading ?? this.isLoading,
      currentGender: currentGender ?? this.currentGender,
      currentLevel: currentLevel ?? this.currentLevel,
      chest: chest ?? this.chest,
      back: back ?? this.back,
      arms: arms ?? this.arms,
      shoulders: shoulders ?? this.shoulders,
      abs: abs ?? this.abs,
      legs: legs ?? this.legs,
    );
  }
}

class WorkoutNotifier extends Notifier<WorkoutState> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();

  @override
  WorkoutState build() {
    return WorkoutState();
  }

  Future<void> fetchWorkoutsIfNeeded(String gender, String level) async {
    String formattedGender = gender.toLowerCase() == 'male' ? 'Man' : 'Woman';

    if (state.currentGender == formattedGender && state.currentLevel == level) {
      return; // Already loaded
    }

    state = state.copyWith(isLoading: true);

    try {
      final results = await Future.wait([
        _workoutRepository.getWorkouts(formattedGender, level, "Chest"),
        _workoutRepository.getWorkouts(formattedGender, level, "Back"),
        _workoutRepository.getWorkouts(formattedGender, level, "Arms"),
        _workoutRepository.getWorkouts(formattedGender, level, "Shoulders"),
        _workoutRepository.getWorkouts(formattedGender, level, "Abs"),
        _workoutRepository.getWorkouts(formattedGender, level, "Legs"),
      ]);

      state = state.copyWith(
        chest: results[0],
        back: results[1],
        arms: results[2],
        shoulders: results[3],
        abs: results[4],
        legs: results[5],
        currentGender: formattedGender,
        currentLevel: level,
        isLoading: false,
      );
    } catch (e) {
      debugPrint("Error fetching workouts: $e");
      state = state.copyWith(isLoading: false);
    }
  }
}

final workoutProvider = NotifierProvider<WorkoutNotifier, WorkoutState>(() {
  return WorkoutNotifier();
});
