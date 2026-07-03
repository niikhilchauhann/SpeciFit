import 'dart:io';
import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  List<HealthDataType> get types {
    if (Platform.isAndroid) {
      return [
        HealthDataType.STEPS,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_AWAKE,
        HealthDataType.SLEEP_SESSION,
      ];
    } else {
      return [
        HealthDataType.STEPS,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.SLEEP_AWAKE,
      ];
    }
  }

  Future<bool> requestPermissions() async {
    bool hasPermissions = await Health().hasPermissions(types) ?? false;
    if (!hasPermissions) {
      try {
        hasPermissions = await Health().requestAuthorization(types);
      } catch (e) {
        debugPrint('Exception in requestAuthorization: $e');
      }
    }
    return hasPermissions;
  }

  Future<int> getSteps(DateTime date) async {
    DateTime start = DateTime(date.year, date.month, date.day);
    DateTime end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    try {
      int? steps = await Health().getTotalStepsInInterval(start, end);
      return steps ?? 0;
    } catch (e) {
      debugPrint('Exception in getSteps: $e');
      return 0;
    }
  }

  Future<double> getSleepHours(DateTime date) async {
    DateTime start = DateTime(date.year, date.month, date.day).subtract(const Duration(hours: 6));
    DateTime end = DateTime(date.year, date.month, date.day, 18, 0, 0);
    try {
      List<HealthDataType> sleepTypes = Platform.isAndroid
          ? [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_SESSION]
          : [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_IN_BED];

      List<HealthDataPoint> sleepData = await Health().getHealthDataFromTypes(
        types: sleepTypes,
        startTime: start,
        endTime: end,
      );

      double asleepMinutes = 0;
      double sessionMinutes = 0;
      double inBedMinutes = 0;

      for (var point in sleepData) {
        final minutes = point.dateTo.difference(point.dateFrom).inMinutes.toDouble();
        if (point.type == HealthDataType.SLEEP_ASLEEP) asleepMinutes += minutes;
        if (point.type == HealthDataType.SLEEP_SESSION) sessionMinutes += minutes;
        if (point.type == HealthDataType.SLEEP_IN_BED) inBedMinutes += minutes;
      }

      double totalMinutes = asleepMinutes > 0 ? asleepMinutes : (sessionMinutes > 0 ? sessionMinutes : inBedMinutes);
      return totalMinutes / 60.0;
    } catch (e) {
      debugPrint('Exception in getSleepHours: $e');
      return 0;
    }
  }
}
