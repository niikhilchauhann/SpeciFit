import '/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '/features/auth/screens/custom_stepper.dart';
import '/features/auth/screens/signin.dart';

class AuthSwitch extends StatefulWidget {
  const AuthSwitch({super.key});

  @override
  State<AuthSwitch> createState() => _AuthSwitchState();
}

class _AuthSwitchState extends State<AuthSwitch>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> isSignIn = ValueNotifier<bool>(false);

  void tooglePage() {
    isSignIn.value = !isSignIn.value;
    _controller.reset();
    _controller.forward();
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
    isSignIn.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.surface,
      body: FadeTransition(
        opacity: _animation,
        child: ValueListenableBuilder<bool>(
          valueListenable: isSignIn,
          builder: (context, signInState, child) {
            return Column(
              children: [
                Expanded(
                  child: signInState
                      ? SignInPage(showRegisterPage: tooglePage)
                      : CustomStepper(showLoginPage: tooglePage),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      signInState
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
                        signInState ? 'Sign Up' : 'Sign In',
                        style: const TextStyle(
                          color: Color(0xff132137),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }
}
