import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String firstname;
  final String gender;
  final int height;
  final int weight;
  final double? bodyFat;
  final int age;
  final String email;
  final String goal;
  final String level;
  final String lifestyle;

  Users({
    required this.firstname,
    required this.gender,
    required this.goal,
    required this.height,
    required this.weight,
    this.bodyFat,
    required this.age,
    required this.email,
    required this.level,
    required this.lifestyle,
  });

  factory Users.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Users(
      firstname: data?['firstname'] ?? '',
      gender: data?['gender'] ?? 'Male',
      height: (data?['height'] is num)
          ? (data!['height'] as num).toInt()
          : int.tryParse(data?['height']?.toString() ?? '0') ?? 0,
      weight: (data?['weight'] is num)
          ? (data!['weight'] as num).toInt()
          : int.tryParse(data?['weight']?.toString() ?? '0') ?? 0,
      bodyFat: (data?['bodyFat'] is num)
          ? (data!['bodyFat'] as num).toDouble()
          : double.tryParse(data?['bodyFat']?.toString() ?? ''),
      age: (data?['age'] is num)
          ? (data!['age'] as num).toInt()
          : int.tryParse(data?['age']?.toString() ?? '0') ?? 0,
      email: data?['email'] ?? '',
      goal: data?['goal'] ?? '',
      level: data?['level'] ?? '',
      lifestyle: data?['lifestyle'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "firstname": firstname,
      "gender": gender,
      "goal": goal,
      "height": height,
      "weight": weight,
      "bodyFat": bodyFat,
      "age": age,
      "level": level,
      "lifestyle": lifestyle,
      "email": email,
    };
  }
}
