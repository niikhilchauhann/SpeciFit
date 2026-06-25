import '/core/utils/exports.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '/core/providers/theme_provider.dart';
import '/core/providers/health_data_provider.dart';

class SleepDetails extends ConsumerStatefulWidget {
  const SleepDetails({super.key});

  @override
  ConsumerState<SleepDetails> createState() => _SleepDetailsState();
}

class _SleepDetailsState extends ConsumerState<SleepDetails> {
  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());
  final double _sleepGoal = 8.0;

  @override
  void dispose() {
    _selectedDateNotifier.dispose();
    super.dispose();
  } // 8 hours goal

  void _showInfoDialog(BuildContext context, TextTheme theme) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      animType: AnimType.rightSlide,
      dismissOnBackKeyPress: true,
      showCloseIcon: true,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text("Points to remember:", style: theme.labelLarge),
          const SizedBox(height: 15),
          Text(
            "A) Sleep data is synchronized directly from Health Connect (Android) or Apple Health (iOS).",
            style: theme.labelLarge,
          ),
          const SizedBox(height: 10),
          Text(
            "B) Make sure your smartwatch or tracking device is actively syncing sleep data to your device's health platform.",
            style: theme.labelLarge,
          ),
          const SizedBox(height: 10),
          Text(
            "C) The general recommended sleep duration for healthy adults is between 7 and 9 hours per night.",
            style: theme.labelLarge,
          ),
          const SizedBox(height: 10),
        ],
      ),
      btnOkOnPress: () {},
      btnOkText: "GOT IT",
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    var theme = Theme.of(context).textTheme;
    
    return ValueListenableBuilder<DateTime>(
      valueListenable: _selectedDateNotifier,
      builder: (context, selectedDate, _) {
        final healthDataAsync = ref.watch(healthDataProvider(selectedDate));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Sleep Details", style: theme.titleMedium),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          iconSize: 20,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 2),
            child: IconButton(
              onPressed: () => _showInfoDialog(context, theme),
              icon: const Icon(CupertinoIcons.question_circle, size: 24),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          s24,
          EasyDateTimeLine(
            initialDate: selectedDate,
            onDateChange: (newDate) {
              _selectedDateNotifier.value = newDate;
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
                dayStrStyle: TextStyle(color: Colors.white, fontSize: 12),
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
          healthDataAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('Error loading sleep data'),
              ),
            ),
            data: (healthData) {
              final sleepHours = healthData.sleepHours;
              double progress = (sleepHours / _sleepGoal).clamp(0.0, 1.0);
              return Column(
                children: [
                  Text(
                    progress >= 1.0 ? "Great Sleep Quality!" : "You need more rest!",
                    style: theme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.indigo.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        CircularPercentIndicator(
                          percent: progress,
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: Colors.indigo.withValues(alpha: 0.6),
                          backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                          backgroundWidth: -1,
                          radius: 115,
                          lineWidth: 15,
                          animation: true,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.nights_stay,
                                size: 30,
                                color: Colors.indigoAccent,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                sleepHours.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 45,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.indigoAccent,
                                ),
                              ),
                              Text("HOURS", style: theme.titleMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.instance.surfaceDark
                          : AppColors.instance.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.insights, color: AppColors.instance.primary),
                            SizedBox(width: 10),
                            Text(
                              "Sleep Insights",
                              style: AppTextStyles.instance.titleLarge,
                            ),
                          ],
                        ),
                        s16,
                        Text(
                          "Getting at least $_sleepGoal hours of sleep is crucial for muscle recovery, cognitive function, and maintaining a healthy metabolism. "
                          "Make sure to avoid heavy meals and caffeine right before bed for optimal deep sleep cycles.",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  s24,
                ],
              );
            },
          ),
        ],
      ),
    );
      },
    );
  }
}
