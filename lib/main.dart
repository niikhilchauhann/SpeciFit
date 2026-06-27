import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '/core/theme/app_theme.dart';
import '/core/providers/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/data/adapters/meal_adapter.dart';
import '/data/adapters/workout_adapter.dart';
import '/features/auth/screens/authstate.dart';

import '/data/adapters/daily_tracker_adapter.dart';
import '/data/adapters/weight_adapter.dart';
import 'firebase_options.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/core/services/home_widget_service.dart';
import '/core/services/health_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await HomeWidgetService.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(CaloriesAdapter());
  Hive.registerAdapter(DailyTrackerAdapter());
  Hive.registerAdapter(WeightTrackerAdapter());
  await Hive.openBox<Workout>('workouts');
  await Hive.openBox<Calories>('calories');
  await Hive.openBox<DailyTracker>('daily_tracker');
  await Hive.openBox<WeightTracker>('weight_tracker');
  await Hive.openBox('autocomplete_cache');
  await Hive.openBox('search_cache');
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> requestPermissions() async {
  if (!kIsWeb) {
    final status = await Permission.activityRecognition.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    if (status.isGranted) {
      debugPrint('Permission granted');
    } else {
      debugPrint('Permission denied');
    }
    
    // Request Health Connect permissions
    await HealthService().requestPermissions();
  } else {
    debugPrint('Permission.activity_recognition is not supported on the web.');
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'SpeciFit',
      theme: isDarkMode ? darkTheme : lightTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthState(),
    );
  }
}
