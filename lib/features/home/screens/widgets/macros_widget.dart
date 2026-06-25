import '/core/utils/exports.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '/core/providers/theme_provider.dart';
import '/core/providers/selected_date_provider.dart';
import '/data/adapters/meal_adapter.dart';


class HomeMacrosWidget extends ConsumerWidget {
  final dynamic macroData;
  const HomeMacrosWidget({super.key, required this.macroData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = ref.watch(themeProvider);
    final isSmall = Res.isMobile(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final caloriesBox = Hive.box<Calories>('calories');

    return ValueListenableBuilder<Box<Calories>>(
      valueListenable: caloriesBox.listenable(),
      builder: (context, box, _) {
        double consumedCalories = 0;
        double consumedProtein = 0;
        double consumedCarbs = 0;
        double consumedFat = 0;

        for (int i = 0; i < box.length; i++) {
          Calories c = box.getAt(i)!;
          if (c.date.year == selectedDate.year &&
              c.date.month == selectedDate.month &&
              c.date.day == selectedDate.day) {
            consumedCalories += c.calories;
            consumedProtein += c.protein;
            consumedCarbs += c.carbohydrates;
            consumedFat += c.fat;
          }
        }

        final targetCalories = double.tryParse(macroData.toString()) ?? 2000.0;
        final targetProtein = (targetCalories * 0.20) / 4;
        final targetCarbs = (targetCalories * 0.55) / 4;
        final targetFat = (targetCalories * 0.25) / 9;

        final consumedData = [
          consumedCalories.toStringAsFixed(0),
          consumedProtein.toStringAsFixed(0),
          consumedCarbs.toStringAsFixed(0),
          consumedFat.toStringAsFixed(0),
        ];

        final targetData = [
          '/${targetCalories.toStringAsFixed(0)}',
          '/${targetProtein.toStringAsFixed(0)}',
          '/${targetCarbs.toStringAsFixed(0)}',
          '/${targetFat.toStringAsFixed(0)}',
        ];

        return GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 1.12,
            crossAxisCount: isSmall ? 2 : 4,
            mainAxisSpacing: isSmall ? 12 : 24,
            crossAxisSpacing: isSmall ? 12 : 24,
          ),
          itemBuilder: (context, index) {
            final colors = [
              AppColors.instance.surface,
              AppColors.instance.onSurface,
              AppColors.instance.primary,
              AppColors.instance.secondary,
            ];
            final fields = ['Calories', 'Protein', 'Carbs', 'Fat'];
            final icons = [
              Icons.local_fire_department,
              Icons.bolt_outlined,
              Icons.energy_savings_leaf_outlined,
              Icons.fastfood_outlined,
            ];
            final subdata = [' kcal', ' g', ' g', ' g'];

            return Container(
              padding: EdgeInsets.all(AppConstants.defPadInner),
              decoration: BoxDecoration(
                color: isDark ? AppColors.instance.surfaceDark : colors[index],
                borderRadius: BorderRadius.circular(AppConstants.defRad),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fields[index],
                        style: AppTextStyles.instance.title.copyWith(
                          fontSize: isSmall ? 18 : 22,
                          color: isDark
                              ? AppColors.instance.onSurfaceDark
                              : ((index > 0 && index < 3)
                                    ? AppColors.instance.onSurfaceDark
                                    : AppColors.instance.onSurface),
                        ),
                      ),
                      CustomRoundButton(
                        color: isDark
                            ? AppColors.instance.backgroundDark
                            : AppColors.instance.background,
                        size: isSmall ? 10 : 13,
                        child: Icon(
                          icons[index],
                          color: isDark
                              ? AppColors.instance.onSurfaceDark
                              : AppColors.instance.primary,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: consumedData[index],
                          style: AppTextStyles.instance.titleLarge.copyWith(
                            fontSize: isSmall ? 24 : 16,
                            color: isDark
                                ? AppColors.instance.onSurfaceDark
                                : ((index > 0 && index < 3)
                                      ? AppColors.instance.onSurfaceDark
                                      : AppColors.instance.onSurface),
                          ),
                        ),
                        TextSpan(
                          text: targetData[index],
                          style: AppTextStyles.instance.titleLarge.copyWith(
                            fontSize: isSmall ? 19 : 21,
                            color: isDark
                                ? Colors.white54
                                : ((index > 0 && index < 3)
                                      ? Colors.white54
                                      : AppColors.instance.onSurface.withValues(
                                          alpha: 0.6,
                                        )),
                          ),
                        ),
                        TextSpan(
                          text: subdata[index],
                          style: AppTextStyles.instance.bodyLarge.copyWith(
                            fontSize: isSmall ? 16 : 18,
                            color: isDark
                                ? Colors.white60
                                : ((index > 0 && index < 3)
                                      ? Colors.white60
                                      : AppColors.instance.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
