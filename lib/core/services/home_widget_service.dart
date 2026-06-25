import 'package:home_widget/home_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '/data/adapters/daily_tracker_adapter.dart';
import '/core/services/health_service.dart';

class HomeWidgetService {
  static const String appGroupId =
      'group.com.edencorp.myfitnessapp'; // Generic app group for iOS
  static const String iOSName = 'SpecifitWidgets';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> updateWidgets(DateTime selectedDate) async {
    if (kIsWeb) return;

    try {
      // 1. Update Water
      final box = Hive.box<DailyTracker>('daily_tracker');
      String key =
          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
      double water = 0.0;
      if (box.containsKey(key)) {
        water = box.get(key)!.water;
      }

      // Calculate progress out of 4000ml (4 liters)
      double maxWater = 4.0;
      double waterProgress = (water / maxWater).clamp(0.0, 1.0);

      await HomeWidget.saveWidgetData<double>('water_level', water);
      await HomeWidget.saveWidgetData<int>(
        'water_progress_int',
        (waterProgress * 100).toInt(),
      );
      await HomeWidget.saveWidgetData<String>(
        'water_text',
        '${(water * 1000).toStringAsFixed(0)} / 4000 ml',
      );
      await HomeWidget.updateWidget(
        androidName: 'WaterWidgetProvider',
        iOSName: iOSName,
      );

      // 2. Update Steps
      int steps = await HealthService().getSteps(selectedDate);
      double maxSteps = 10000.0;
      double stepsProgress = (steps / maxSteps).clamp(0.0, 1.0);

      await HomeWidget.saveWidgetData<int>('steps_count', steps);
      await HomeWidget.saveWidgetData<int>(
        'steps_progress_int',
        (stepsProgress * 100).toInt(),
      );
      await HomeWidget.saveWidgetData<String>('steps_text', '$steps / 10000');
      await HomeWidget.updateWidget(
        androidName: 'StepsWidgetProvider',
        iOSName: iOSName,
      );
    } catch (e) {
      debugPrint('Error updating home widgets: $e');
    }
  }

  static Future<void> saveCalories(double calories) async {
    if (kIsWeb) return;

    try {
      await HomeWidget.saveWidgetData<double>('calories_count', calories);
      await HomeWidget.saveWidgetData<String>(
        'calories_text',
        '${calories.toStringAsFixed(0)} kcal',
      );
      await HomeWidget.updateWidget(
        androidName: 'CaloriesWidgetProvider',
        iOSName: iOSName,
      );
    } catch (e) {
      debugPrint('Error updating calories widget: $e');
    }
  }
}
