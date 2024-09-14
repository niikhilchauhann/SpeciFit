import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String firstname;
  final String gender;
  final int height;
  final int weight;
  final int age;
  final String email;
  final String password;
  final String goal;
  final String level;
  final String lifestyle;

  Users({
    required this.firstname,
    required this.gender,
    required this.goal,
    required this.height,
    required this.weight,
    required this.age,
    required this.email,
    required this.password,
    required this.level,
    required this.lifestyle,
  });

  factory Users.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Users(
      firstname: data?['firstname'],
      gender: data?['gender'],
      height: data?['height'],
      weight: data?['weight'],
      age: data?['age'],
      email: data?['email'],
      password: data?['password'],
      goal: data?['goal'],
      level: data?['level'],
      lifestyle: data?['lifestyle'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "firstname": firstname,
      "gender": gender,
      "goal": goal,
      "height": height,
      "weight": weight,
      "age": age,
      "level": level,
      "lifestyle": lifestyle,
      "email": email,
      "pasword": password,
    };
  }
}
