import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final streakProvider = FutureProvider<int>((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int currentStreak = prefs.getInt('current_streak') ?? 0;
  String? lastOpenedStr = prefs.getString('last_opened_date');

  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);

  if (lastOpenedStr != null) {
    DateTime lastOpened = DateTime.parse(lastOpenedStr);
    int differenceInDays = today.difference(lastOpened).inDays;

    if (differenceInDays == 1) {
      // Opened yesterday, increment streak
      currentStreak++;
    } else if (differenceInDays > 1) {
      // Missed a day, reset streak
      currentStreak = 1;
    }
    // If differenceInDays == 0, already opened today, keep streak
  } else {
    // First time opening the app
    currentStreak = 1;
  }

  await prefs.setInt('current_streak', currentStreak);
  await prefs.setString('last_opened_date', today.toIso8601String());

  return currentStreak;
});
