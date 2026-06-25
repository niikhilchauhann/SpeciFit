import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '/core/providers/auth_provider.dart';
import '/core/providers/user_provider.dart';
import '/data/models/users_model.dart';
import '/data/adapters/weight_adapter.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? message;

  ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.message,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? message,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      message: message,
    );
  }
}

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return ProfileState();
  }

  void clearMessage() {
    state = state.copyWith(message: null, error: null);
  }

  Future<void> saveUserData({
    required String firstname,
    required String gender,
    required String goal,
    required int height,
    required int weight,
    required int age,
    required String email,
    required String level,
    required String lifestyle,
  }) async {
    state = state.copyWith(isSaving: true, error: null, message: null);
    try {
      final authUser = ref.read(authProvider);
      if (authUser != null) {
        final updatedUser = Users(
          firstname: firstname,
          gender: gender,
          goal: goal,
          height: height,
          weight: weight,
          age: age,
          email: email,
          level: level,
          lifestyle: lifestyle,
        );

        await ref
            .read(userProvider.notifier)
            .saveUser(authUser.uid, updatedUser);

        var weightBox = Hive.box<WeightTracker>('weight_tracker');
        DateTime today = DateTime.now();
        String key = "${today.year}-${today.month}-${today.day}";
        weightBox.put(
          key,
          WeightTracker(date: today, weight: weight.toDouble()),
        );

        state = state.copyWith(
          isSaving: false,
          message: "Profile updated successfully!",
        );
      } else {
        state = state.copyWith(
          isSaving: false,
          error: "User not authenticated.",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: "Failed to update profile: $e",
      );
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(error: null, message: null);
    try {
      await ref.read(authProvider.notifier).sendPasswordResetEmail(email);
      state = state.copyWith(message: "Password reset email sent!");
    } catch (e) {
      state = state.copyWith(error: "Failed to send reset email: $e");
    }
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(() {
      return ProfileController();
    });
