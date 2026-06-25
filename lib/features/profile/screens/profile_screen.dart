import '/core/utils/exports.dart';
import '/features/auth/screens/message_dialogs.dart';
import '/core/providers/user_provider.dart';
import '/core/providers/profile_controller.dart';
import '/core/widgets/custom_text_field.dart';
import '/core/widgets/custom_dropdown.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchesController = TextEditingController();

  final ValueNotifier<String> _gender = ValueNotifier<String>('Male');
  final ValueNotifier<String> _goal = ValueNotifier<String>('Lose weight');
  final ValueNotifier<String> _level = ValueNotifier<String>('Beginner');
  final ValueNotifier<String> _lifestyle = ValueNotifier<String>('Sedentary');
  final ValueNotifier<int> _age = ValueNotifier<int>(16);
  bool _initialized = false;

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _goals = ['Lose weight', 'Gain weight', 'Maintain weight'];
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _lifestyles = [
    'Sedentary',
    'Lightly active',
    'Moderately active',
    'Very active',
    'Extremely active',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    super.dispose();
  }

  void _initUserData(Users? userData) {
    if (userData != null && !_initialized) {
      _nameController.text = userData.firstname;
      _emailController.text = userData.email;
      _weightController.text = userData.weight.toString();

      _gender.value = userData.gender;
      if (!_genders.contains(_gender.value)) _gender.value = _genders.first;

      _goal.value = userData.goal;
      if (!_goals.contains(_goal.value)) _goal.value = _goals.first;

      _level.value = userData.level;
      if (!_levels.contains(_level.value)) _level.value = _levels.first;

      _lifestyle.value = userData.lifestyle;
      if (!_lifestyles.contains(_lifestyle.value)) {
        _lifestyle.value = _lifestyles.first;
      }

      _age.value = userData.age;

      // Convert cm to ft/in
      double totalInches = userData.height / 2.54;
      int feet = (totalInches / 12).floor();
      int inches = (totalInches % 12).round();
      _feetController.text = feet.toString();
      _inchesController.text = inches.toString();
      
      _initialized = true;
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    int feet = int.tryParse(_feetController.text) ?? 0;
    int inches = int.tryParse(_inchesController.text) ?? 0;
    double totalInches = ((feet * 12) + inches).toDouble();
    int heightInCm = (totalInches * 2.54).round();

    ref.read(profileControllerProvider.notifier).saveUserData(
      firstname: _nameController.text.trim(),
      gender: _gender.value,
      goal: _goal.value,
      height: heightInCm,
      weight: int.tryParse(_weightController.text) ?? 0,
      age: _age.value,
      email: _emailController.text,
      level: _level.value,
      lifestyle: _lifestyle.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = ref.watch(userProvider);
    final profileState = ref.watch(profileControllerProvider);
    
    // Initialize data once
    if (!_initialized && userData != null) {
      _initUserData(userData);
    }

    ref.listen<ProfileState>(profileControllerProvider, (previous, next) {
      if (next.message != null) {
        successMsg(next.message!, context);
        ref.read(profileControllerProvider.notifier).clearMessage();
      }
      if (next.error != null) {
        errorMsg(next.error!, context);
        ref.read(profileControllerProvider.notifier).clearMessage();
      }
    });

    if (userData == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.instance.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Preferences & Profile",
          style: AppTextStyles.instance.titleLarge,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Personal Information"),
              CustomTextField(
                label: "Name",
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextField(
                    label: "Email Address (Read Only)",
                    controller: _emailController,
                    readOnly: true,
                    suffixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(profileControllerProvider.notifier).resetPassword(_emailController.text),
                    child: Text(
                      "Forget Password? Send Reset Email",
                      style: TextStyle(
                        color: AppColors.instance.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: "Weight (kg)",
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _age,
                      builder: (context, ageVal, _) {
                        return CustomDropdown(
                          label: "Age",
                          items: List.generate(100, (i) => (i + 1).toString()),
                          value: ageVal.toString(),
                          onChanged: (v) {
                            _age.value = int.parse(v!);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: "Height (ft)",
                      controller: _feetController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: "Height (in)",
                      controller: _inchesController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Fitness Profile"),
              ValueListenableBuilder<String>(
                valueListenable: _gender,
                builder: (context, val, _) {
                  return CustomDropdown(
                    label: "Gender",
                    items: _genders,
                    value: val,
                    onChanged: (v) => _gender.value = v!,
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: _goal,
                builder: (context, val, _) {
                  return CustomDropdown(
                    label: "Primary Goal",
                    items: _goals,
                    value: val,
                    onChanged: (v) => _goal.value = v!,
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: _level,
                builder: (context, val, _) {
                  return CustomDropdown(
                    label: "Activity Level",
                    items: _levels,
                    value: val,
                    onChanged: (v) => _level.value = v!,
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: _lifestyle,
                builder: (context, val, _) {
                  return CustomDropdown(
                    label: "Lifestyle",
                    items: _lifestyles,
                    value: val,
                    onChanged: (v) => _lifestyle.value = v!,
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.instance.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: profileState.isSaving ? null : _saveProfile,
                  child: profileState.isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Update Profile",
                          style: AppTextStyles.instance.titleLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTextStyles.instance.titleLarge.copyWith(
          color: AppColors.instance.primary,
        ),
      ),
    );
  }
}
