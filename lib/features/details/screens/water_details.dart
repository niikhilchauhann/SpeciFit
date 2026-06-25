import '/core/utils/exports.dart';
import '/core/providers/selected_date_provider.dart';

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import '/core/providers/theme_provider.dart';
import '/core/providers/daily_tracker_provider.dart';

class WaterDetails extends ConsumerWidget {
  const WaterDetails({super.key});

  final double _maxWaterLevel = 4.0; // 4 liters = 4000 ml

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = ref.watch(themeProvider);
    var theme = Theme.of(context).textTheme;

    // Use a ValueNotifier for local date selection to avoid setState
    final selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Water Tracker", style: theme.titleMedium),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          iconSize: 20,
        ),
        elevation: 0,
      ),
      body: ValueListenableBuilder<DateTime>(
        valueListenable: selectedDateNotifier,
        builder: (context, selectedDate, _) {
          // Note: To fully refactor without setState, we use Riverpod for the tracker data.
          // Since the dailyTrackerProvider uses the global selectedDateProvider, 
          // we should update the global date when the local timeline changes.
          final tracker = ref.watch(dailyTrackerProvider);
          final double currentWaterLevelLiters = tracker.water;
          final double progress = (currentWaterLevelLiters / _maxWaterLevel).clamp(0.0, 1.0);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              s24,
              EasyDateTimeLine(
                initialDate: selectedDate,
                onDateChange: (newDate) {
                  selectedDateNotifier.value = newDate;
                  ref.read(selectedDateProvider.notifier).updateDate(newDate);
                },
                headerProps: EasyHeaderProps(
                  monthPickerType: MonthPickerType.switcher,
                  dateFormatter: const DateFormatter.fullDateDMY(),
                  monthStyle: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDateStyle: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                dayProps: EasyDayProps(
                  dayStructure: DayStructure.dayStrDayNum,
                  activeDayStyle: DayStyle(
                    dayNumStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    dayStrStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      color: AppColors.instance.primary,
                    ),
                  ),
                  inactiveDayStyle: DayStyle(
                    dayNumStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    dayStrStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              s24,
              Text(
                progress >= 1.0 
                    ? "Hydration Goal Achieved!" 
                    : "Keep Hydrating!",
                style: theme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              s24,
              Center(
                child: SizedBox(
                  height: 250,
                  width: 250,
                  child: LiquidCircularProgressIndicator(
                    value: progress,
                    valueColor: AlwaysStoppedAnimation(const Color(0xFF2633C5).withValues(alpha: 0.8)),
                    backgroundColor: isDark ? AppColors.instance.backgroundDark : AppColors.instance.background,
                    borderColor: const Color(0xFF2633C5).withValues(alpha: 0.2),
                    borderWidth: 5.0,
                    direction: Axis.vertical,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_drink, color: isDark ? Colors.white : Colors.black87, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          "${(currentWaterLevelLiters * 1000).toStringAsFixed(0)} ml",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          "/ 4000 ml",
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              s24,
              s24,
              Text(
                'Quick Add Water',
                style: AppTextStyles.instance.titleLarge,
              ),
              s16,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAddWaterButton(context, ref, 0.25, "+ 250 ml", isDark),
                  _buildAddWaterButton(context, ref, 0.5, "+ 500 ml", isDark),
                  _buildAddWaterButton(context, ref, 1.0, "+ 1 Liter", isDark),
                ],
              ),
              s24,
              ElevatedButton.icon(
                onPressed: () => ref.read(dailyTrackerProvider.notifier).resetWater(),
                icon: Icon(Icons.refresh),
                label: Text("Reset Intake"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.instance.surfaceDark : AppColors.instance.surface,
                  foregroundColor: AppColors.instance.primary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              s24,
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddWaterButton(BuildContext context, WidgetRef ref, double amountLiters, String label, bool isDark) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () => ref.read(dailyTrackerProvider.notifier).increaseWater(amountLiters),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.instance.surfaceDark : AppColors.instance.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.instance.primary.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.instance.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
