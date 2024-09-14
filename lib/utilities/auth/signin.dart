import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../export.dart';
import 'forgot_password.dart';

class SignInPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const SignInPage({
    Key? key,
    required this.showRegisterPage,
  }) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  bool processStarted = false;

  Future<void> signIn() async {
    setState(() {
      processStarted = true;
    });
    FocusScope.of(context).unfocus();
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _signInEmailController.text.trim(),
              password: _signInPasswordController.text.trim())
          .then((value) {
        successMsg("Signed in as ${FirebaseAuth.instance.currentUser!.email}",
            context);
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        processStarted = false;
      });
      errorMsg(e.toString(), context);
    }
  }

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(primarySwatch: Colors.green),
      child: Scaffold(
        backgroundColor: bgcolor,
        appBar: AppBar(
          toolbarHeight: 70,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
          centerTitle: true,
          title: const Text(
            "Sign In",
            style: h2black,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 15),
                const Text(
                  "Hey there, so good to see you again!\nLet's get you started.",
                  style: h2black,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.emailAddress,
                  controller: _signInEmailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This is a required field';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      borderSide: BorderSide(width: 1, color: Colors.black45),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    label: const Text("Email"),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      obscureText: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.visiblePassword,
                      controller: _signInPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This is a required field';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                          borderSide:
                              BorderSide(width: 1, color: Colors.black45),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        label: const Text("Password"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          createRoute(
                            const ForgotPassword(),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: signIn,
                  child: Ink(
                    height: 50,
                    width: MediaQuery.of(context).size.width - 80,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.green[600],
                        boxShadow: kElevationToShadow[4]),
                    child: Center(
                      child: processStarted
                          ? const SizedBox(
                              height: 50,
                              width: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                color: bgcolor,
                              ),
                            )
                          : const Text(
                              "Sign In",
                              textAlign: TextAlign.center,
                              style: h3white,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
