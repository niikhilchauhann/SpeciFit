import 'package:hive_flutter/hive_flutter.dart';

class WeightTracker {
  late DateTime date;
  double weight;

  WeightTracker({required DateTime date, required this.weight}) {
    this.date = DateTime(date.year, date.month, date.day);
  }
}

class WeightTrackerAdapter extends TypeAdapter<WeightTracker> {
  @override
  final typeId = 3;

  @override
  WeightTracker read(BinaryReader reader) {
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt() * 1000);
    final weight = reader.readDouble();
    return WeightTracker(date: date, weight: weight);
  }

  @override
  void write(BinaryWriter writer, WeightTracker obj) {
    writer.writeInt(obj.date.millisecondsSinceEpoch ~/ 1000);
    writer.writeDouble(obj.weight);
  }
}
