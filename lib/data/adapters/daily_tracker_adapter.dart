import 'package:hive_flutter/hive_flutter.dart';

class DailyTracker {
  late DateTime date;
  double water;
  int steps;
  double sleepHours;

  DailyTracker({
    required DateTime date,
    required this.water,
    required this.steps,
    required this.sleepHours,
  }) {
    this.date = DateTime(date.year, date.month, date.day);
  }
}

class DailyTrackerAdapter extends TypeAdapter<DailyTracker> {
  @override
  final typeId = 2;

  @override
  DailyTracker read(BinaryReader reader) {
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt() * 1000);
    final water = reader.readDouble();
    final steps = reader.readInt();
    final sleepHours = reader.readDouble();
    return DailyTracker(
      date: date,
      water: water,
      steps: steps,
      sleepHours: sleepHours,
    );
  }

  @override
  void write(BinaryWriter writer, DailyTracker obj) {
    writer.writeInt(obj.date.millisecondsSinceEpoch ~/ 1000);
    writer.writeDouble(obj.water);
    writer.writeInt(obj.steps);
    writer.writeDouble(obj.sleepHours);
  }
}
