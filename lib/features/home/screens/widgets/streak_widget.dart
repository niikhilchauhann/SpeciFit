import '/core/utils/exports.dart';

import '/core/providers/theme_provider.dart';
import '/core/providers/streak_provider.dart';

class StreakWidget extends ConsumerStatefulWidget {
  const StreakWidget({super.key});

  @override
  ConsumerState<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends ConsumerState<StreakWidget> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = ref.watch(themeProvider);
    final streakAsync = ref.watch(streakProvider);

    return streakAsync.when(
      loading: () => Container(
        height: 80,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.instance.surfaceDark
              : AppColors.instance.surface,
          borderRadius: BorderRadius.circular(AppConstants.defRadOuter),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox(),
      data: (streak) {
        int tier = streak ~/ 100;
        int currentGoal = (tier + 1) * 100;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.defPadOuter,
            vertical: AppConstants.defPad,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.instance.surfaceDark
                : AppColors.instance.surface,
            borderRadius: BorderRadius.circular(AppConstants.defRad),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.instance.backgroundDark
                      : AppColors.instance.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_tethering,
                  size: AppConstants.defIconSize,
                  color: AppColors.instance.primary,
                ),
              ),
              w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Goals of the movement',
                          style: AppTextStyles.instance.titleSmall,
                        ),
                        if (tier > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.workspace_premium,
                                  size: 12,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${tier}x',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '$streak out of $currentGoal days',
                      style: AppTextStyles.instance.body.copyWith(
                        color: AppColors.instance.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department,
                  size: AppConstants.defIconSize,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
