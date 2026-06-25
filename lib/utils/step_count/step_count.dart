import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';

class StepCountState {
  final int stepCount;
  final String pedestrianStatus;

  StepCountState({this.stepCount = 0, this.pedestrianStatus = 'unavailable'});

  StepCountState copyWith({int? stepCount, String? pedestrianStatus}) {
    return StepCountState(
      stepCount: stepCount ?? this.stepCount,
      pedestrianStatus: pedestrianStatus ?? this.pedestrianStatus,
    );
  }
}

class StepCountNotifier extends Notifier<StepCountState> {
  @override
  StepCountState build() {
    startListening();
    return StepCountState();
  }

  void startListening() {
    Pedometer.stepCountStream.listen((StepCount stepCount) {
      state = state.copyWith(stepCount: stepCount.steps);
    }, onError: (error) {});

    Pedometer.pedestrianStatusStream.listen((PedestrianStatus status) {
      state = state.copyWith(pedestrianStatus: status.status);
    }, onError: (error) {});
  }
}

final stepCountProvider = NotifierProvider<StepCountNotifier, StepCountState>(
  () {
    return StepCountNotifier();
  },
);
