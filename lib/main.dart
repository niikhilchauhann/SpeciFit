import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:specifit/utilities/notifications/notification_service.dart';
import 'package:specifit/utilities/step_count/step_count.dart';
import 'firebase_options.dart';
import 'helpers/adapters/meal_adapter.dart';
import 'helpers/adapters/workout_adapter.dart';
import 'utilities/auth/authstate.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  MobileAds.instance.initialize();
  await Permission.notification.request();
  await Permission.activityRecognition.request();
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(CaloriesAdapter());
  await Hive.openBox<Workout>('workouts');
  await Hive.openBox<Calories>('calories');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const FlexScheme usedScheme = FlexScheme.aquaBlue;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark),
    );

    return ChangeNotifierProvider(
      create: (_) => StepCountProvider()..startListening(),
      child: MaterialApp(
        home: const AuthState(),
        theme: FlexThemeData.light(
            useMaterial3: true,
            fontFamily: "Poppins",
            scheme: usedScheme,
            useMaterial3ErrorColors: true,
            textTheme: CustomThemeData.customTextTheme),
        darkTheme: FlexThemeData.dark(
            useMaterial3: true,
            fontFamily: "Poppins",
            scheme: usedScheme,
            useMaterial3ErrorColors: true,
            textTheme: CustomThemeData.customTextTheme),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class CustomThemeData {
  static var customTextTheme = const TextTheme(
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(height: 1.8),
      labelSmall: TextStyle(fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontWeight: FontWeight.w600),
      labelLarge: TextStyle(fontWeight: FontWeight.w600));
}
