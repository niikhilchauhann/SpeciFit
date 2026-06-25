import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/core/providers/auth_provider.dart';
import '/data/models/users_model.dart';
import '/data/repositories/user_repository.dart';

class UserNotifier extends Notifier<Users?> {
  final UserRepository _userRepository = UserRepository();

  @override
  Users? build() {
    return null; // Initial state is null
  }

  Future<void> fetchUser(String uid) async {
    final user = await _userRepository.getUser(uid);
    state = user;
  }

  Future<void> saveUser(String uid, Users user) async {
    await _userRepository.saveUser(uid, user);
    state = user;
  }

  Future<void> updateWeight(String uid, int newWeight) async {
    await _userRepository.updateUserField(uid, {'weight': newWeight});
    if (state != null) {
      state = Users(
        firstname: state!.firstname,
        gender: state!.gender,
        goal: state!.goal,
        height: state!.height,
        weight: newWeight,
        age: state!.age,
        email: state!.email,
        level: state!.level,
        lifestyle: state!.lifestyle,
      );
    }
  }
}

final userProvider = NotifierProvider<UserNotifier, Users?>(() {
  return UserNotifier();
});

final userInitializationProvider = FutureProvider<void>((ref) async {
  final authUser = ref.watch(authProvider);
  if (authUser != null) {
    await ref.read(userProvider.notifier).fetchUser(authUser.uid);
    final u = ref.read(userProvider);
    if (u != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userGender', u.gender);
      prefs.setString('userLevel', u.level);
    }
  }
});
