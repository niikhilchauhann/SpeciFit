import 'package:hive_flutter/hive_flutter.dart';

class Calories {
  late DateTime date;
  String name;
  int id;
  double calories;
  double protein;
  double carbohydrates;
  double fat;

  Calories(
      {required DateTime date,
      required this.name,
      required this.id,
      required this.calories,
      required this.protein,
      required this.carbohydrates,
      required this.fat}) {
    this.date = DateTime(date.year, date.month, date.day);
  }
}

class CaloriesAdapter extends TypeAdapter<Calories> {
  @override
  final typeId = 1;

  @override
  Calories read(BinaryReader reader) {
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt() * 1000);
    final name = reader.readString();
    final id = reader.readInt();
    final calories = reader.readDouble();
    final protein = reader.readDouble();
    final carbohydrates = reader.readDouble();
    final fat = reader.readDouble();
    return Calories(
        date: date,
        name: name,
        id: id,
        calories: calories,
        protein: protein,
        carbohydrates: carbohydrates,
        fat: fat);
  }

  @override
  void write(BinaryWriter writer, Calories obj) {
    writer.writeInt(obj.date.millisecondsSinceEpoch ~/ 1000);
    writer.writeString(obj.name);
    writer.writeInt(obj.id);
    writer.writeDouble(obj.calories);
    writer.writeDouble(obj.protein);
    writer.writeDouble(obj.carbohydrates);
    writer.writeDouble(obj.fat);
  }
}
