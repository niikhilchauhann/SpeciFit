import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class WorkoutLvlTilesM extends StatelessWidget {
  final VoidCallback ontap;
  final String levelname;
  final String level;

  const WorkoutLvlTilesM({
    super.key,
    required this.ontap,
    required this.levelname,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: ontap,
      child: Ink(
        height: 195,
        decoration: BoxDecoration(
          color: AppColors.instance.secondary,
          image: const DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/man/man.jpg"),
          ),
          boxShadow: [AppColors.instance.shadow],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              right: 20,
              child: Text(
                levelname,
                textAlign: TextAlign.center,
                style: AppTextStyles.instance.titleSmall.copyWith(
                  color: AppColors.instance.onSurfaceDark,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(level, style: AppTextStyles.instance.body),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutLvlTilesW extends StatelessWidget {
  final VoidCallback ontap;
  final String levelname;
  final String level;

  const WorkoutLvlTilesW({
    super.key,
    required this.ontap,
    required this.levelname,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: ontap,
      child: Ink(
        height: 195,
        decoration: BoxDecoration(
          image: const DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/woman/women.jpg"),
          ),
          borderRadius: BorderRadius.circular(15),
          color: AppColors.instance.secondary,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                levelname,
                textAlign: TextAlign.center,
                style: AppTextStyles.instance.titleSmall.copyWith(
                  color: AppColors.instance.onSurfaceDark,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(level, style: AppTextStyles.instance.body),
            ),
          ],
        ),
      ),
    );
  }
}
