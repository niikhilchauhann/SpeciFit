import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../mobile_structure.dart';
import 'authswitch.dart';

class AuthState extends StatelessWidget {
  const AuthState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return const MobileStructure();
          } else {
            return const AuthSwitch();
          }
        }),
      ),
    );
  }
}
