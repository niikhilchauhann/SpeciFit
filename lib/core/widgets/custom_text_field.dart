import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool readOnly;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextAlign textAlign;
  final TextStyle? style;
  final InputDecoration? decoration;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.textAlign = TextAlign.start,
    this.style,
    this.decoration,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      textAlign: textAlign,
      textInputAction: textInputAction,
      style:
          style ??
          AppTextStyles.instance.body.copyWith(
            color: readOnly
                ? Colors.grey
                : (isDark ? Colors.white : Colors.black87),
          ),
      validator:
          validator ??
          (value) => value == null || value.isEmpty ? 'Required' : null,
      decoration:
          decoration ??
          InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: isDark
                ? AppColors.instance.surfaceDark
                : Colors.grey.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            suffixIcon: suffixIcon,
          ),
    );
  }
}
