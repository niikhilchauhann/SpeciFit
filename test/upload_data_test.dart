import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:specifit/firebase_options.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('Upload workouts to Firebase', () async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // await uploadWorkoutsDatabase();
  });
}
