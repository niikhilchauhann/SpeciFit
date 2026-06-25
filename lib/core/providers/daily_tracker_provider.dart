import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/data/adapters/daily_tracker_adapter.dart';
import '/core/providers/selected_date_provider.dart';
import '/core/services/home_widget_service.dart';

class DailyTrackerNotifier extends Notifier<DailyTracker> {
  late final Box<DailyTracker> _box;
  late DateTime _currentDate;

  @override
  DailyTracker build() {
    _box = Hive.box<DailyTracker>('daily_tracker');
    _currentDate = ref.watch(selectedDateProvider);
    return _getOrCreateDailyTracker(_currentDate);
  }

  DailyTracker _getOrCreateDailyTracker(DateTime date) {
    String key = "${date.year}-${date.month}-${date.day}";
    if (_box.containsKey(key)) {
      return _box.get(key)!;
    } else {
      final tracker = DailyTracker(date: date, water: 0.0, steps: 0, sleepHours: 0.0);
      _box.put(key, tracker);
      return tracker;
    }
  }

  void increaseWater(double amountLiters) {
    String key = "${_currentDate.year}-${_currentDate.month}-${_currentDate.day}";
    final tracker = _getOrCreateDailyTracker(_currentDate);
    tracker.water += amountLiters;
    _box.put(key, tracker);
    HomeWidgetService.updateWidgets(_currentDate);
    state = DailyTracker(date: tracker.date, water: tracker.water, steps: tracker.steps, sleepHours: tracker.sleepHours);
  }

  void resetWater() {
    String key = "${_currentDate.year}-${_currentDate.month}-${_currentDate.day}";
    final tracker = _getOrCreateDailyTracker(_currentDate);
    tracker.water = 0.0;
    _box.put(key, tracker);
    HomeWidgetService.updateWidgets(_currentDate);
    state = DailyTracker(date: tracker.date, water: tracker.water, steps: tracker.steps, sleepHours: tracker.sleepHours);
  }
}

final dailyTrackerProvider = NotifierProvider<DailyTrackerNotifier, DailyTracker>(() {
  return DailyTrackerNotifier();
});
