import '/core/utils/exports.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

import '/core/providers/theme_provider.dart';
import '/core/providers/health_data_provider.dart';

class StepsDetails extends ConsumerStatefulWidget {
  const StepsDetails({super.key});

  @override
  ConsumerState<StepsDetails> createState() => _StepsDetailsState();
}

class _StepsDetailsState extends ConsumerState<StepsDetails> {
  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());

  @override
  void dispose() {
    _selectedDateNotifier.dispose();
    super.dispose();
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
            title: Text("Steps Details", style: theme.titleMedium),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: 20,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 2),
                child: IconButton(
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.infoReverse,
                      animType: AnimType.rightSlide,
                      dismissOnBackKeyPress: true,
                      showCloseIcon: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text("Points to remember:", style: theme.labelLarge),
                          const SizedBox(height: 15),
                          Text(
                            "A) Step data is synchronized directly from Health Connect (Android) or Apple Health (iOS).",
                            style: theme.labelLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "B) Make sure your smartwatch or tracking device is actively syncing step data to your device's health platform.",
                            style: theme.labelLarge,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      btnOkOnPress: () {},
                      btnOkText: "GOT IT",
                    ).show();
                  },
                  icon: const Icon(CupertinoIcons.question_circle, size: 24),
                ),
              ),
            ],
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 10),
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
                    dayNumStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    dayStrStyle: const TextStyle(color: Colors.white, fontSize: 12),
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
              const SizedBox(height: 24),
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
                    child: Text('Error loading step data'),
                  ),
                ),
                data: (healthData) {
                  int yourSteps = healthData.steps;

                  return Column(
                    children: [
                      Text(
                        yourSteps >= 10000
                            ? "Great Job Today!"
                            : "You Have To Take\nMore Steps!",
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
                                  color: Colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                            CircularPercentIndicator(
                              percent: yourSteps < 10000 ? yourSteps.toDouble() / 10000 : 1.0,
                              circularStrokeCap: CircularStrokeCap.round,
                              progressColor: Colors.orange.withValues(alpha: 0.5),
                              backgroundColor: Colors.orange.withValues(alpha: 0.2),
                              backgroundWidth: -1,
                              radius: 115,
                              lineWidth: 15,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.directions_run_rounded,
                                    size: 30,
                                    color: Colors.orange,
                                  ),
                                  Text(
                                    yourSteps.toString(),
                                    style: const TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  Text("STEPS", style: theme.titleMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActivityStats(
                            icon: CupertinoIcons.flame,
                            value: "${(yourSteps * 0.05).toStringAsFixed(1)} kcal",
                            iconColor: Colors.purple,
                          ),
                          ActivityStats(
                            icon: Icons.watch_later_outlined,
                            value: "${(yourSteps * 0.015).toStringAsFixed(1)} min",
                            iconColor: Colors.green,
                          ),
                          ActivityStats(
                            icon: Icons.location_on,
                            value: "${((yourSteps * 2.4) / 3281).toStringAsFixed(2)} km",
                            iconColor: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text('Achievements', style: AppTextStyles.instance.titleLarge),
                      const SizedBox(height: 16),
                      AchievementsWidget(
                        title: 'BEGINNER',
                        value: '500',
                        isComplete: yourSteps > 500,
                      ),
                      AchievementsWidget(
                        title: 'MR. NOBODY',
                        value: '1000',
                        isComplete: yourSteps > 1000,
                      ),
                      AchievementsWidget(
                        title: 'THE HEALTH CONCIOUS',
                        value: '10k',
                        isComplete: yourSteps > 10000,
                      ),
                      AchievementsWidget(
                        title: 'ATHLETE',
                        value: '20k',
                        isComplete: yourSteps > 20000,
                      ),
                      AchievementsWidget(
                        title: 'ELITE RUNNER',
                        value: '50k',
                        isComplete: yourSteps > 50000,
                      ),
                      AchievementsWidget(
                        title: 'MASTER',
                        value: '75k',
                        isComplete: yourSteps > 75000,
                      ),
                      AchievementsWidget(
                        title: 'THE CONQUERER',
                        value: '100k',
                        isComplete: yourSteps > 100000,
                      ),
                      const SizedBox(height: 30),
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

class AchievementsWidget extends StatelessWidget {
  const AchievementsWidget({
    super.key,
    required this.title,
    required this.value,
    required this.isComplete,
  });
  final String title;
  final String value;
  final bool isComplete;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? Colors.green
              : Theme.of(context).colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isComplete ? Icons.lock_open : Icons.lock,
                size: 18,
                color: isComplete
                    ? Colors.green
                    : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 1,
                  color: isComplete
                      ? Colors.green
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
          Text(
            '$value steps',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isComplete
                  ? Colors.green
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityStats extends StatelessWidget {
  const ActivityStats({
    super.key,
    required this.icon,
    required this.value,
    required this.iconColor,
  });
  final dynamic icon;
  final dynamic value;
  final dynamic iconColor;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 5),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
