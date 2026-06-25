import '/core/utils/exports.dart';
import '/core/widgets/custom_route.dart';
import '/core/widgets/custom_text_field.dart';
import '/core/widgets/custom_button.dart';
import '/core/providers/auth_provider.dart';
import '/features/auth/screens/forgot_password.dart';
import '/features/auth/screens/message_dialogs.dart';

class SignInPage extends ConsumerStatefulWidget {
  final VoidCallback showRegisterPage;
  const SignInPage({super.key, required this.showRegisterPage});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  final ValueNotifier<bool> _processStarted = ValueNotifier<bool>(false);

  Future<void> signIn() async {
    _processStarted.value = true;
    FocusScope.of(context).unfocus();
    try {
      final authProviderInstance = ref.read(authProvider.notifier);
      await authProviderInstance.signIn(
        _signInEmailController.text,
        _signInPasswordController.text,
      );
      if (!mounted) return;
      successMsg("Signed in successfully", context);
    } catch (e) {
      if (!mounted) return;
      _processStarted.value = false;
      errorMsg(e.toString(), context);
    }
  }

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _processStarted.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.instance.surface,
      appBar: AppBar(
        toolbarHeight: 70,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.instance.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              SizedBox(height: 10),
              Text(
                "Welcome Back! 👋",
                style: AppTextStyles.instance.headline.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: AppColors.instance.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Log in to continue your fitness journey.",
                style: AppTextStyles.instance.label.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 50),
              CustomTextField(
                label: "Email",
                controller: _signInEmailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextField(
                    label: "Password",
                    controller: _signInPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, createRoute(ForgotPassword()));
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppColors.instance.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              ValueListenableBuilder<bool>(
                valueListenable: _processStarted,
                builder: (context, processStarted, child) {
                  return CustomButton(
                    text: "Sign In",
                    onTap: signIn,
                    isLoading: processStarted,
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
