import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:flutter/foundation.dart';

class StepCountProvider with ChangeNotifier {
  int _stepCount = 0;
  dynamic _pedestrianStatus = 'unavailable';

  int get stepCount => _stepCount;
  String get pedestrianStatus => _pedestrianStatus;

  void startListening() {
    Pedometer.stepCountStream.listen((StepCount stepCount) {
      _stepCount = stepCount.steps;
      notifyListeners();
    }, onError: (error) {});

    Pedometer.pedestrianStatusStream.listen((PedestrianStatus status) {
      _pedestrianStatus = status.status;
      notifyListeners();
    }, onError: (error) {});
  }
}
