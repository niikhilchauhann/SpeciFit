import '/core/utils/exports.dart';

import '/core/providers/auth_provider.dart';
import '/core/widgets/custom_text_field.dart';
import '/core/widgets/custom_button.dart';
import '/features/auth/screens/message_dialogs.dart';

class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({super.key});

  @override
  ConsumerState<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword> {
  final _emailController = TextEditingController();
  final ValueNotifier<bool> _processStarted = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    _processStarted.dispose();
    super.dispose();
  }

  Future forgotPassword() async {
    _processStarted.value = true;
    FocusScope.of(context).unfocus();
    try {
      final authProviderInstance = ref.read(authProvider.notifier);
      await authProviderInstance.sendPasswordResetEmail(_emailController.text);
      if (!mounted) return;
      _processStarted.value = false;
      successMsg(
        "Password reset link has been sent to your email address.",
        context,
      );
    } catch (e) {
      if (!mounted) return;
      _processStarted.value = false;
      errorMsg(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Theme(
      data: ThemeData(primarySwatch: Colors.green),
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                height: screenSize.height / 2.4,
                width: screenSize.width - 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Don't Worry!",
                          style: AppTextStyles.instance.title,
                        ),
                        Text(
                          "We'll send you a password reset link to your registered email address.",
                          style: AppTextStyles.instance.titleSmall,
                        ),
                        const SizedBox(height: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CustomTextField(
                              label: "Enter Your Registered Email",
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This is a required field';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.center,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _processStarted,
                            builder: (context, processStarted, child) {
                              return CustomButton(
                                text: "Send Link",
                                onTap: forgotPassword,
                                isLoading: processStarted,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
