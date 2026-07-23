import 'package:firebase_auth/firebase_auth.dart';
import '/core/utils/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/features/auth/screens/message_dialogs.dart';
import '/core/providers/auth_provider.dart';
import '/core/providers/user_provider.dart';

class CustomStepper extends ConsumerStatefulWidget {
  final VoidCallback showLoginPage;
  const CustomStepper({super.key, required this.showLoginPage});

  @override
  ConsumerState<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends ConsumerState<CustomStepper> {
  final nameController = TextEditingController();
  final feetController = TextEditingController();
  final inchesController = TextEditingController();
  final weightController = TextEditingController();
  final bodyFatController = TextEditingController();
  final ValueNotifier<bool> dontKnowBodyFat = ValueNotifier(false);
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormState>();
  final _heightKey = GlobalKey<FormState>();
  final _weightKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final ValueNotifier<int> _heightInCm = ValueNotifier(0);
  int initialAge = 16;
  final ValueNotifier<int> currentStep = ValueNotifier(0);
  final ValueNotifier<String> selectedGender = ValueNotifier('');
  final ValueNotifier<String> selectedGoal = ValueNotifier('');
  final ValueNotifier<String> selectedLevel = ValueNotifier('');
  final ValueNotifier<String> selectedLifestyle = ValueNotifier('');
  final ValueNotifier<bool> _processStarted = ValueNotifier<bool>(false);
  late ValueNotifier<int> _age;

  final _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _age = ValueNotifier(initialAge);
  }

  @override
  void dispose() {
    feetController.dispose();
    inchesController.dispose();
    weightController.dispose();
    bodyFatController.dispose();
    dontKnowBodyFat.dispose();
    _email.dispose();
    _password.dispose();
    _processStarted.dispose();

    currentStep.dispose();
    selectedGender.dispose();
    selectedGoal.dispose();
    selectedLevel.dispose();
    selectedLifestyle.dispose();
    _age.dispose();
    _heightInCm.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void animateToNext() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
    );
  }

  void animateToPrevious() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
    );
  }

  void nextStep() {
    if (currentStep.value == 0) {
      if (selectedGender.value != '') {
        currentStep.value++;
        animateToNext();
      }
    } else if (currentStep.value == 1) {
      if (selectedGoal.value != '') {
        currentStep.value++;
        animateToNext();
      }
    } else if (currentStep.value == 2) {
      if (selectedLevel.value != '') {
        currentStep.value++;
        animateToNext();
      }
    } else if (currentStep.value == 3) {
      if (_nameKey.currentState!.validate()) {
        currentStep.value++;
        FocusScope.of(context).nextFocus();
        animateToNext();
      }
    } else if (currentStep.value == 4) {
      if (_heightKey.currentState!.validate()) {
        _convertHeight();
        currentStep.value++;
        FocusScope.of(context).unfocus();
        animateToNext();
      }
    } else if (currentStep.value == 5) {
      if (_weightKey.currentState!.validate()) {
        currentStep.value++;
        FocusScope.of(context).unfocus();
        animateToNext();
      }
    } else if (currentStep.value == 6) {
      if (_age.value >= 12) {
        currentStep.value++;
        animateToNext();
      }
    } else if (currentStep.value == 7) {
      if (selectedLifestyle.value != '') {
        currentStep.value++;
        animateToNext();
      }
    }
  }

  void _convertHeight() {
    int feet = int.tryParse(feetController.text) ?? 0;
    int inches = int.tryParse(inchesController.text) ?? 0;
    double totalInches = ((feet * 12) + inches).toDouble();
    double heightInCm = totalInches * 2.54;
    _heightInCm.value = heightInCm.round();
  }

  void showAuthMessage() {
    if (!mounted) return;
    final user = ref.read(authProvider);
    successMsg("Signed in as ${user?.email}", context);
  }

  void showErrorMessage([
    String error = "We found some error in your details.",
  ]) {
    if (!mounted) return;
    _processStarted.value = false;
    errorMsg(error, context);
  }

  Future signUp() async {
    try {
      final authProviderInstance = ref.read(authProvider.notifier);
      final userProviderInstance = ref.read(userProvider.notifier);

      final cred = await authProviderInstance.signUp(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (cred.user != null) {
        final userData = Users(
          firstname: nameController.text,
          gender: selectedGender.value,
          height: _heightInCm.value,
          weight: int.parse(weightController.text),
          bodyFat: dontKnowBodyFat.value
              ? null
              : double.tryParse(bodyFatController.text),
          age: _age.value,
          goal: selectedGoal.value,
          level: selectedLevel.value,
          lifestyle: selectedLifestyle.value,
          email: _email.text,
        );

        await userProviderInstance.saveUser(cred.user!.uid, userData);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userGender', selectedGender.value);
        prefs.setString('userLevel', selectedLevel.value);
        showAuthMessage();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _processStarted.value = false;
      String errorMessage = "An error occurred during registration.";
      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "The account already exists for that email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is badly formatted.";
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      errorMsg(errorMessage, context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      _processStarted.value = false;
      errorMsg("Failed to save user data: ${e.message}", context);
    } catch (e) {
      if (!mounted) return;
      _processStarted.value = false;
      errorMsg("An unexpected error occurred. Please try again.", context);
    }
  }

  List<Widget> _buildStepTitles() {
    final List<Widget> ageItems = [];
    for (int i = 1; i <= 100; i++) {
      ageItems.add(
        SizedBox(
          height: 48,
          child: Center(
            child: Text(
              "$i",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 24,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TitleWidget(title: "What is your gender?"),
          Column(
            children: [
              AboutYouOne(
                listenable: selectedGender,
                title: 'Male',
                icon: Icons.male,
                onTap: () => selectedGender.value = 'Male',
              ),
              SizedBox(height: 20.0),
              AboutYouOne(
                listenable: selectedGender,
                title: 'Female',
                icon: Icons.female,
                onTap: () => selectedGender.value = 'Female',
              ),
            ],
          ),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TitleWidget(title: "Select your primary fitness goal"),
          Column(
            children: [
              AboutYouTwo(
                listenable: selectedGoal,
                icon: Icons.trending_down,
                title: 'Lose weight',
                subtitle: 'Shred extra fat & gain muscles',
                onTap: () => selectedGoal.value = 'Lose weight',
              ),
              SizedBox(height: 20.0),
              AboutYouTwo(
                listenable: selectedGoal,
                icon: Icons.trending_up,
                title: 'Gain weight',
                subtitle: 'Get big & strong while staying lean',
                onTap: () => selectedGoal.value = 'Gain weight',
              ),
              SizedBox(height: 20.0),
              AboutYouTwo(
                listenable: selectedGoal,
                icon: Icons.monitor_weight,
                title: 'Maintain weight',
                subtitle: 'Stay in shape and feel great',
                onTap: () => selectedGoal.value = 'Maintain weight',
              ),
            ],
          ),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TitleWidget(title: "What's your current activity level?"),
          Column(
            children: [
              AboutYouTwo(
                listenable: selectedLevel,
                icon: Icons.directions_walk,
                title: 'Beginner',
                subtitle: 'I can easily perform 0-2 push ups',
                onTap: () => selectedLevel.value = 'Beginner',
              ),
              SizedBox(height: 20.0),
              AboutYouTwo(
                listenable: selectedLevel,
                icon: Icons.directions_run,
                title: 'Intermediate',
                subtitle: 'I can easily perform 4-6 push ups',
                onTap: () => selectedLevel.value = 'Intermediate',
              ),
              SizedBox(height: 20.0),
              AboutYouTwo(
                listenable: selectedLevel,
                icon: Icons.fitness_center,
                title: 'Advanced',
                subtitle: 'I can easily perform 8-12 push ups',
                onTap: () => selectedLevel.value = 'Advanced',
              ),
            ],
          ),
        ],
      ),
      Form(
        key: _nameKey,
        child: Column(
          children: [
            TitleWidget(title: "What should we call you?"),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                cursorHeight: 30,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.instance.primary,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This is a required field';
                  } else if (value.characters.length < 4) {
                    return 'Name must have atleast 4 characters.';
                  }
                  return null;
                },
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey.shade400,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.instance.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Form(
            key: _heightKey,
            child: Column(
              children: [
                TitleWidget(title: "What is your height?"),
                SizedBox(height: 50),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontFamily: "Poppins",
                            color: AppColors.instance.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          controller: feetController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Req';
                            } else if (int.parse(value) < 3) {
                              return 'Err';
                            } else if (int.parse(value) > 8) {
                              return 'Err';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.instance.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "ft",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Poppins",
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 40),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontFamily: "Poppins",
                            color: AppColors.instance.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          controller: inchesController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            } else if (int.parse(value) < 0 ||
                                int.parse(value) > 12) {
                              return 'Err';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.instance.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "in",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Poppins",
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      Form(
        key: _weightKey,
        child: Column(
          children: [
            TitleWidget(title: "Weight & Body Fat"),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontFamily: "Poppins",
                        color: AppColors.instance.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: weightController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Req';
                        } else if (int.parse(value) < 30 ||
                            int.parse(value) > 220) {
                          return 'Err';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Weight",
                        hintStyle: TextStyle(fontSize: 16),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.instance.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "kg",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Poppins",
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: dontKnowBodyFat,
                      builder: (context, dontKnow, _) {
                        return TextFormField(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontFamily: "Poppins",
                            color: dontKnow
                                ? Colors.grey
                                : AppColors.instance.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          controller: bodyFatController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          enabled: !dontKnow,
                          validator: (value) {
                            if (dontKnow) return null;
                            if (value == null || value.isEmpty) {
                              return 'Req';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Body Fat",
                            hintStyle: TextStyle(fontSize: 16),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.instance.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "%",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Poppins",
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ValueListenableBuilder<bool>(
              valueListenable: dontKnowBodyFat,
              builder: (context, dontKnow, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: dontKnow,
                      onChanged: (val) {
                        dontKnowBodyFat.value = val ?? false;
                        if (val == true) {
                          bodyFatController.clear();
                        }
                      },
                      activeColor: AppColors.instance.primary,
                    ),
                    Text(
                      "I don't know my fat percentage",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 36),
            Expanded(
              child: Column(
                children: [
                  Text(
                    "Note: We use the Mifflin-St Jeor equation by default. If you provide body fat, we use the Katch-McArdle Formula for better precision.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ValueListenableBuilder<String>(
                        valueListenable: selectedGender,
                        builder: (context, gender, _) {
                          String imagePath = gender.toLowerCase() == 'female'
                              ? 'assets/images/female_fat_chart.jpeg'
                              : 'assets/images/male_fat_chart.jpg';
                          return Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            alignment: Alignment.topCenter,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Column(
        children: [
          TitleWidget(title: "How old are you?"),
          SizedBox(height: 50),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CupertinoPicker(
              itemExtent: 48,
              onSelectedItemChanged: (int index) {
                _age.value = index + 1;
              },
              scrollController: FixedExtentScrollController(
                initialItem: _age.value - 1,
              ),
              backgroundColor: Colors.transparent,
              useMagnifier: true,
              magnification: 1.25,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  color: AppColors.instance.primary.withValues(alpha: 0.1),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: AppColors.instance.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              children: ageItems,
            ),
          ),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              TitleWidget(title: "Describe your typical week"),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: LifestyleWidget(
                      listenable: selectedLifestyle,
                      title: 'Sedentary',
                      subtitle: 'Little/No exercise',
                      onTap: () => selectedLifestyle.value = 'Sedentary',
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: LifestyleWidget(
                      listenable: selectedLifestyle,
                      title: 'Lightly active',
                      subtitle: 'Exercise 1-3 days',
                      onTap: () => selectedLifestyle.value = 'Lightly active',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: LifestyleWidget(
                      listenable: selectedLifestyle,
                      title: 'Moderately active',
                      subtitle: 'Exercise 3-5 days',
                      onTap: () =>
                          selectedLifestyle.value = 'Moderately active',
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: LifestyleWidget(
                      listenable: selectedLifestyle,
                      title: 'Very active',
                      subtitle: 'Exercise 6-7 days',
                      onTap: () => selectedLifestyle.value = 'Very active',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              LifestyleWidget(
                listenable: selectedLifestyle,
                title: 'Extremely active',
                subtitle: 'Physical job / Training 2x/day',
                onTap: () => selectedLifestyle.value = 'Extremely active',
              ),
            ],
          ),
        ],
      ),
      Column(
        children: [
          Text(
            "Account Details",
            textAlign: TextAlign.center,
            style: AppTextStyles.instance.headline,
          ),
          SizedBox(height: 8),
          Text(
            "Almost done! Secure your account.",
            textAlign: TextAlign.center,
            style: AppTextStyles.instance.label.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.emailAddress,
                  controller: _email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                        width: 1.5,
                        color: AppColors.instance.primary,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.red.shade300,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1.5, color: Colors.red),
                    ),
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    label: Text("Email Address"),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  controller: _password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                        width: 1.5,
                        color: AppColors.instance.primary,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.red.shade300,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(width: 1.5, color: Colors.red),
                    ),
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    label: Text("Password"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Call _buildStepTitles once. No AnimatedBuilder means no complete rebuilds!
    final stepTitles = _buildStepTitles();

    return Theme(
      data: ThemeData(primarySwatch: Colors.blue), // Will be overridden
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    splashRadius: 25,
                    onPressed: () {
                      if (currentStep.value > 0) {
                        currentStep.value--;
                        animateToPrevious();
                      } else {
                        if (ModalRoute.of(context)?.canPop ?? false) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.instance.onSurface,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ValueListenableBuilder<int>(
                        valueListenable: currentStep,
                        builder: (context, step, _) {
                          return LinearProgressIndicator(
                            minHeight: 8,
                            value: (step + 1) / stepTitles.length,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.instance.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  IconButton(
                    splashRadius: 25,
                    onPressed: () {
                      if (ModalRoute.of(context)?.canPop ?? false) {
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.instance.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: stepTitles
                      .map(
                        (step) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Center(child: step),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 35),
              ValueListenableBuilder<int>(
                valueListenable: currentStep,
                builder: (context, step, _) {
                  if (step == stepTitles.length - 1) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          _processStarted.value = true;
                          signUp();
                        } else {
                          showErrorMessage();
                        }
                      },
                      child: Ink(
                        width: MediaQuery.of(context).size.width - 48,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.instance.primary,
                              AppColors.instance.blue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.instance.primary.withValues(
                                alpha: 0.3,
                              ),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _processStarted,
                          builder: (context, processStarted, child) {
                            return Center(
                              child: processStarted
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: RepaintBoundary(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Theme.of(context).colorScheme.surface,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Create Account",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.surface,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: nextStep,
                      child: Ink(
                        width: MediaQuery.of(context).size.width - 48,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.instance.primary,
                              AppColors.instance.blue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.instance.primary.withValues(
                                alpha: 0.3,
                              ),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          "Continue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
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

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: AppTextStyles.instance.headline.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 26,
      ),
    );
  }
}

class LifestyleWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final ValueNotifier<String> listenable;
  final VoidCallback onTap;

  const LifestyleWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.listenable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ValueListenableBuilder<String>(
        valueListenable: listenable,
        builder: (context, selectedValue, _) {
          bool isSelected = selectedValue == title;
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: 110,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.instance.primary.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? AppColors.instance.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.instance.primary.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.instance.titleSmall.copyWith(
                    color: isSelected
                        ? AppColors.instance.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.instance.label.copyWith(
                    color: isSelected
                        ? AppColors.instance.primary.withValues(alpha: 0.8)
                        : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AboutYouOne extends StatelessWidget {
  const AboutYouOne({
    super.key,
    required this.listenable,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final ValueNotifier<String> listenable;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ValueListenableBuilder<String>(
        valueListenable: listenable,
        builder: (context, selectedValue, child) {
          bool isSelected = selectedValue == title;
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.instance.primary.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? AppColors.instance.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.instance.primary.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
              borderRadius: BorderRadius.circular(15),
            ),
            height: 80,
            width: double.infinity,
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isSelected
                      ? AppColors.instance.primary
                      : Colors.grey.shade600,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.instance.titleSmall.copyWith(
                      color: isSelected
                          ? AppColors.instance.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.instance.primary),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AboutYouTwo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ValueNotifier<String> listenable;
  final VoidCallback onTap;

  const AboutYouTwo({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.listenable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ValueListenableBuilder<String>(
        valueListenable: listenable,
        builder: (context, selectedValue, _) {
          bool isSelected = selectedValue == title;
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.instance.primary.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? AppColors.instance.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.instance.primary.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
              borderRadius: BorderRadius.circular(15),
            ),
            height: 90,
            width: double.infinity,
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isSelected
                      ? AppColors.instance.primary
                      : Colors.grey.shade600,
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.instance.titleSmall.copyWith(
                          color: isSelected
                              ? AppColors.instance.primary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.instance.label.copyWith(
                          color: isSelected
                              ? AppColors.instance.primary.withValues(
                                  alpha: 0.8,
                                )
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.instance.primary),
              ],
            ),
          );
        },
      ),
    );
  }
}
