import '/core/utils/exports.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import '/core/widgets/custom_route.dart';
import '/features/details/screens/water_details.dart';
import '/core/providers/theme_provider.dart';
import '/core/providers/daily_tracker_provider.dart';

class WaterTrackerWidget extends ConsumerWidget {
  const WaterTrackerWidget({super.key});

  final double _maxWaterLevel = 4.0; // 4 liters = 4000 ml

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = ref.watch(themeProvider);
    final tracker = ref.watch(dailyTrackerProvider);
    final double currentWaterLevelLiters = tracker.water;
    final double progress = currentWaterLevelLiters / _maxWaterLevel;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, createRoute(const WaterDetails()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(
        horizontal: AppConstants.defPad,
        vertical: AppConstants.defPad,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.instance.surfaceDark
            : AppColors.instance.surface,
        borderRadius: BorderRadius.circular(AppConstants.defRadOuter),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Water Intake',
                style: AppTextStyles.instance.title.copyWith(
                  fontSize: 18,
                  color: isDark
                      ? AppColors.instance.onSurfaceDark
                      : AppColors.instance.onSurface,
                ),
              ),
              CustomRoundButton(
                onPressed: () => ref.read(dailyTrackerProvider.notifier).resetWater(),
                color: isDark
                    ? AppColors.instance.backgroundDark
                    : AppColors.instance.background,
                size: 10,
                child: Icon(
                  Icons.local_drink_outlined,
                  color: isDark
                      ? AppColors.instance.onSurfaceDark
                      : AppColors.instance.primary,
                ),
              ),
            ],
          ),
          s20,
          SizedBox(
            height: 280,
            width: 280,
            child: RepaintBoundary(
              child: LiquidCircularProgressIndicator(
                value: progress > 1.0 ? 1.0 : progress,
                valueColor: AlwaysStoppedAnimation(Color(0xff125ce1)),
                backgroundColor: Color(0xff2f90f7),
                borderColor: Color(0xff147ced),
                borderWidth: 0,
                direction: Axis.vertical,
                center: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(width: 0),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%\nTODAY',
                            style: AppTextStyles.instance.bodyLarge
                                .copyWith(
                                  fontSize: 16,
                                  color: AppColors.instance.onSurfaceDark,
                                ),
                            textAlign: TextAlign.left,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  CustomRoundButton(
                                    color: AppColors.instance.background,
                                    onPressed: () => ref.read(dailyTrackerProvider.notifier).increaseWater(0.350),
                                    size: 2,
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                      color: Color(0xff147ced),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '350 ml',
                                    style: AppTextStyles.instance.labelLarge
                                        .copyWith(
                                          color: AppColors
                                              .instance
                                              .onSurfaceDark,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  CustomRoundButton(
                                    color: AppColors.instance.background,
                                    onPressed: () => ref.read(dailyTrackerProvider.notifier).increaseWater(0.275),
                                    size: 2,
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                      color: Color(0xff147ced),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '275 ml',
                                    style: AppTextStyles.instance.labelLarge
                                        .copyWith(
                                          color: AppColors
                                              .instance
                                              .onSurfaceDark,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  CustomRoundButton(
                                    color: AppColors.instance.background,
                                    onPressed: () => ref.read(dailyTrackerProvider.notifier).increaseWater(0.200),
                                    size: 2,
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                      color: Color(0xff147ced),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '200 ml',
                                    style: AppTextStyles.instance.labelLarge
                                        .copyWith(
                                          color: AppColors
                                              .instance
                                              .onSurfaceDark,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 48),
                      Text(
                        currentWaterLevelLiters >= _maxWaterLevel
                            ? 'Goal exceeded by ${((currentWaterLevelLiters - _maxWaterLevel) * 1000).toStringAsFixed(0)} ml!'
                            : '${((_maxWaterLevel - currentWaterLevelLiters) * 1000).toStringAsFixed(0)} ml left to reach goal!',
                        style: AppTextStyles.instance.labelLarge.copyWith(
                          color: AppColors.instance.onSurfaceDark,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
      ),
    );
  }
}

