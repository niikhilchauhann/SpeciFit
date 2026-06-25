import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/data/repositories/auth_repository.dart';

class AuthNotifier extends Notifier<User?> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  User? build() {
    return _authRepository.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    await _authRepository.signIn(email, password);
    state = _authRepository.currentUser;
  }

  Future<UserCredential> signUp(String email, String password) async {
    final cred = await _authRepository.signUp(email, password);
    state = _authRepository.currentUser;
    return cred;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authRepository.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});
