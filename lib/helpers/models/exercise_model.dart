import 'dart:convert';

List<Exercise> exerciseFromJson(String str) =>
    List<Exercise>.from(json.decode(str).map((x) => Exercise.fromJson(x)));

String exerciseToJson(List<Exercise> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Exercise {
  Exercise({
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.name,
    required this.target,
  });

  String bodyPart;
  String equipment;
  String gifUrl;
  String name;
  String target;

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        bodyPart: json["bodyPart"],
        equipment: json["equipment"],
        gifUrl: json["gifUrl"],
        name: json["name"],
        target: json["target"],
      );

  Map<String, dynamic> toJson() => {
        "bodyPart": bodyPart,
        "equipment": equipment,
        "gifUrl": gifUrl,
        "name": name,
        "target": target,
      };
}

class ExerciseData {
  final List<Exercise> chest;
  final List<Exercise> back;
  final List<Exercise> shoulders;
  final List<Exercise> arms;
  final List<Exercise> legs;
  final List<Exercise> abs;

  final List<Exercise> chest1;
  final List<Exercise> back1;
  final List<Exercise> arms1;
  final List<Exercise> legs1;
  final List<Exercise> abs1;

  final List<Exercise> chest2;
  final List<Exercise> back2;
  final List<Exercise> arms2;
  final List<Exercise> legs2;
  final List<Exercise> abs2;

  ExerciseData({
    required this.chest,
    required this.back,
    required this.shoulders,
    required this.arms,
    required this.legs,
    required this.abs,
    required this.chest1,
    required this.back1,
    required this.arms1,
    required this.legs1,
    required this.abs1,
    required this.chest2,
    required this.back2,
    required this.arms2,
    required this.legs2,
    required this.abs2,
  });

  factory ExerciseData.fromJson(Map<String, dynamic> json) {
    List<Exercise> chest = (json['Chest'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> back = (json['Back'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> shoulders = (json['Shoulders'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> arms = (json['Arms'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> legs = (json['Legs'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> abs = (json['Abs'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();

    List<Exercise> chest1 = (json['Chest'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> back1 = (json['Back'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> arms1 = (json['Arms'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> legs1 = (json['Legs'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> abs1 = (json['Abs'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();

    List<Exercise> chest2 = (json['Chest'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> back2 = (json['Back'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> arms2 = (json['Arms'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> legs2 = (json['Legs'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();
    List<Exercise> abs2 = (json['Abs'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e))
        .toList();

    return ExerciseData(
      chest: chest,
      back: back,
      shoulders: shoulders,
      arms: arms,
      legs: legs,
      abs: abs,
      chest1: chest1,
      back1: back1,
      arms1: arms1,
      legs1: legs1,
      abs1: abs1,
      chest2: chest2,
      back2: back2,
      arms2: arms2,
      legs2: legs2,
      abs2: abs2,
    );
  }
}
