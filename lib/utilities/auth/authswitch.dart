import 'package:flutter/material.dart';

import '../export.dart';
import 'custom_stepper.dart';
import 'signin.dart';

class AuthSwitch extends StatefulWidget {
  const AuthSwitch({super.key});

  @override
  State<AuthSwitch> createState() => _AuthSwitchState();
}

class _AuthSwitchState extends State<AuthSwitch>
    with SingleTickerProviderStateMixin {
  bool isSignIn = false;
  bool isSignUp = true;
  void tooglePage() {
    setState(() {
      isSignIn = !isSignIn;
      _controller.reset();
      _controller.forward();
    });
  }

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      body: FadeTransition(
        opacity: _animation,
        child: Column(
          children: [
            Expanded(
              child: isSignIn
                  ? SignInPage(
                      showRegisterPage: tooglePage,
                    )
                  : CustomStepper(
                      showLoginPage: tooglePage,
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSignIn
                      ? 'Don\'t have an account? '
                      : 'Already have an account? ',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                TextButton(
                  onPressed: tooglePage,
                  child: Text(
                    isSignIn ? 'Sign Up' : 'Sign In',
                    style: const TextStyle(
                      color: Color(0xff132137),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
