import 'package:cloud_firestore/cloud_firestore.dart';
import '/data/models/gym_workout_model.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<GymWorkoutModel>> getWorkouts(
    String gender,
    String level,
    String muscleGroup,
  ) async {
    final querySnapshot = await _firestore
        .collection(gender)
        .doc(level)
        .collection(muscleGroup)
        .get();

    return querySnapshot.docs
        .map((doc) => GymWorkoutModel.fromSnapshot(doc))
        .toList();
  }
}
