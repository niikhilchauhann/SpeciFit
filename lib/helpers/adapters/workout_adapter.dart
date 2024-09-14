import 'package:hive_flutter/hive_flutter.dart';

class Workout {
  late DateTime date;
  int timeSpent;

  Workout({required DateTime date, required this.timeSpent}) {
    this.date = DateTime(date.year, date.month, date.day);
  }
}

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final typeId = 0;

  @override
  Workout read(BinaryReader reader) {
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt() * 1000);
    final timeSpent = reader.readInt();
    return Workout(date: date, timeSpent: timeSpent);
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer.writeInt(obj.date.millisecondsSinceEpoch ~/ 1000);
    writer.writeInt(obj.timeSpent);
  }
}
