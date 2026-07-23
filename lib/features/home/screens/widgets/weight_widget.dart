import '/core/utils/exports.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '/core/providers/theme_provider.dart';
import '/core/providers/selected_date_provider.dart';
import '/data/adapters/weight_adapter.dart';
import '/core/providers/user_provider.dart';
import '/core/providers/auth_provider.dart';
import '/core/providers/goal_weight_provider.dart';


class WeightWidget extends ConsumerStatefulWidget {
  const WeightWidget({super.key});

  @override
  ConsumerState<WeightWidget> createState() => _WeightWidgetState();
}

class _WeightWidgetState extends ConsumerState<WeightWidget> {
  final ValueNotifier<String> _selectedPeriod = ValueNotifier<String>('Week');
  final List<String> periods = const ['Year', 'Month', 'Week', 'Day'];
  late Box<WeightTracker> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<WeightTracker>('weight_tracker');
  }

  @override
  void dispose() {
    _selectedPeriod.dispose();
    super.dispose();
  }

  void _showUpdateDialog(DateTime selectedDate, double currentWeight, double goalWeight) {
    final TextEditingController weightController = TextEditingController(
      text: currentWeight.toString(),
    );
    final TextEditingController goalController = TextEditingController(
      text: goalWeight.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        bool isDark = ref.watch(themeProvider);
        return AlertDialog(
          backgroundColor: isDark
              ? AppColors.instance.surfaceDark
              : AppColors.instance.surface,
          title: Text(
            'Update Weight',
            style: TextStyle(
              color: isDark
                  ? AppColors.instance.onSurfaceDark
                  : AppColors.instance.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: isDark
                      ? AppColors.instance.onSurfaceDark
                      : AppColors.instance.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Current Weight (kg)',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: isDark
                      ? AppColors.instance.onSurfaceDark
                      : AppColors.instance.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Goal Weight (kg)',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                double newWeight =
                    double.tryParse(weightController.text) ?? currentWeight;
                double newGoal =
                    double.tryParse(goalController.text) ?? goalWeight;

                ref.read(goalWeightProvider.notifier).updateWeight(newGoal);

                String key = "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                box.put(
                  key,
                  WeightTracker(date: selectedDate, weight: newWeight),
                );

                final authState = ref.read(authProvider);
                if (authState != null) {
                  await ref.read(userProvider.notifier).addWeightTrack(
                    authState.uid,
                    selectedDate,
                    newWeight,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.instance.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  List<FlSpot> _getChartData(
    String period,
    DateTime selectedDate,
    int joinYear,
    double currentWeight,
  ) {
    List<FlSpot> spots = [];
    int currentYear = DateTime.now().year;

    if (period == 'Year') {
      int startYear = joinYear;
      if (startYear > currentYear) startYear = currentYear;
      int yearCount = currentYear - startYear + 1;

      for (int i = 0; i < yearCount; i++) {
        int targetYear = startYear + i;
        double w = currentWeight;
        WeightTracker? lastTrackerInYear;
        for (var t in box.values) {
          if (t.date.year == targetYear) {
            if (lastTrackerInYear == null ||
                t.date.isAfter(lastTrackerInYear.date)) {
              lastTrackerInYear = t;
            }
          }
        }
        if (lastTrackerInYear != null) w = lastTrackerInYear.weight;
        spots.add(FlSpot(i.toDouble(), w));
      }
    } else if (period == 'Month') {
      for (int i = 0; i < 12; i++) {
        int targetMonth = i + 1;
        double w = currentWeight;
        WeightTracker? lastInMonth;
        for (var t in box.values) {
          if (t.date.year == selectedDate.year && t.date.month == targetMonth) {
            if (lastInMonth == null || t.date.isAfter(lastInMonth.date)) {
              lastInMonth = t;
            }
          }
        }
        if (lastInMonth != null) w = lastInMonth.weight;
        spots.add(FlSpot(i.toDouble(), w));
      }
    } else if (period == 'Week') {
      for (int i = 0; i < 4; i++) {
        double w = currentWeight;
        WeightTracker? lastInWeek;
        for (var t in box.values) {
          if (t.date.year == selectedDate.year &&
              t.date.month == selectedDate.month) {
            int weekNum = ((t.date.day - 1) ~/ 7);
            if (weekNum > 3) weekNum = 3;
            if (weekNum == i) {
              if (lastInWeek == null || t.date.isAfter(lastInWeek.date)) {
                lastInWeek = t;
              }
            }
          }
        }
        if (lastInWeek != null) w = lastInWeek.weight;
        spots.add(FlSpot(i.toDouble(), w));
      }
    } else if (period == 'Day') {
      DateTime monday = selectedDate.subtract(
        Duration(days: selectedDate.weekday - 1),
      );
      for (int i = 0; i < 7; i++) {
        DateTime day = monday.add(Duration(days: i));
        String key = "${day.year}-${day.month}-${day.day}";
        double w = box.containsKey(key)
            ? box.get(key)!.weight
            : currentWeight;
        spots.add(FlSpot(i.toDouble(), w));
      }
    }
    return spots;
  }

  List<String> _getChartLabels(
    String period,
    DateTime selectedDate,
    int joinYear,
  ) {
    int currentYear = DateTime.now().year;
    if (period == 'Year') {
      List<String> labels = [];
      int startYear = joinYear;
      if (startYear > currentYear) startYear = currentYear;
      for (int i = 0; i <= (currentYear - startYear); i++) {
        labels.add((startYear + i).toString());
      }
      return labels;
    } else if (period == 'Month') {
      return [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
    } else if (period == 'Week') {
      return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
    } else if (period == 'Day') {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final u = ref.watch(userProvider);
    final goalWeight = ref.watch(goalWeightProvider);
    
    double baseWeight = 80.0;
    if (u != null) {
      baseWeight = u.weight.toDouble();
    }

    return ValueListenableBuilder<Box<WeightTracker>>(
      valueListenable: box.listenable(),
      builder: (context, boxTracker, _) {
        double currentWeight = baseWeight;
        double initialWeight = baseWeight;
        int joinYear = selectedDate.year;

        if (boxTracker.isNotEmpty) {
          WeightTracker? oldest;
          WeightTracker? mostRecent;
          
          for (var tracker in boxTracker.values) {
            if (oldest == null || tracker.date.isBefore(oldest.date)) {
              oldest = tracker;
            }
            
            // Find most recent up to selectedDate
            if (tracker.date.isBefore(selectedDate) || tracker.date.isAtSameMomentAs(selectedDate)) {
              if (mostRecent == null || tracker.date.isAfter(mostRecent.date)) {
                mostRecent = tracker;
              }
            }
          }
          
          if (oldest != null) {
            joinYear = oldest.date.year;
          }
          if (mostRecent != null) {
            currentWeight = mostRecent.weight;
          }
        }

        double progress = 0;
        if (initialWeight == goalWeight) {
          progress = (currentWeight == goalWeight) ? 100 : 0;
        } else {
          double totalToLoseOrGain = (goalWeight - initialWeight).abs();
          double amountMoved = (currentWeight - initialWeight).abs();
          bool isGainingGoal = goalWeight > initialWeight;
          bool isMovingRightDirection = isGainingGoal
              ? (currentWeight >= initialWeight)
              : (currentWeight <= initialWeight);

          if (isMovingRightDirection) {
            progress = (amountMoved / totalToLoseOrGain) * 100;
            if (progress > 100) progress = 100;
          } else {
            progress = 0;
          }
        }

        return Container(
          height: 460,
          padding: EdgeInsets.all(AppConstants.defPadOuter * 1.6),
          margin: EdgeInsets.symmetric(horizontal: AppConstants.defPadOuter),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.instance.surfaceDark
                : AppColors.instance.primary,
            borderRadius: BorderRadius.all(
              Radius.circular(AppConstants.defRadOuter),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weight Data',
                    style: AppTextStyles.instance.headlineSmall.copyWith(
                      color: AppColors.instance.onSurfaceDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showUpdateDialog(selectedDate, currentWeight, goalWeight),
                    child: Icon(
                      Icons.more_horiz,
                      size: 38,
                      color: AppColors.instance.onSurfaceDark,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MiniTextWidget(
                    unitValue: currentWeight.toStringAsFixed(1),
                    unitType: ' kg',
                    unitDesc: 'Current',
                  ),
                  MiniTextWidget(
                    unitValue: goalWeight.toStringAsFixed(1),
                    unitType: ' kg',
                    unitDesc: 'Goal',
                  ),
                  MiniTextWidget(
                    unitValue: progress.toStringAsFixed(0),
                    unitType: ' %',
                    unitDesc: 'Progress',
                  ),
                ],
              ),
              s24,
              ValueListenableBuilder<String>(
                valueListenable: _selectedPeriod,
                builder: (context, selectedPeriod, child) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: periods.map((period) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: period == 'Day'
                                  ? 0
                                  : AppConstants.defPadOuter * 2.5,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                _selectedPeriod.value = period;
                              },
                              child: Text(
                                period,
                                style: AppTextStyles.instance.labelLarge.copyWith(
                                  color: selectedPeriod == period
                                      ? AppColors.instance.onSurfaceDark
                                      : Colors.white54,
                                  fontWeight: selectedPeriod == period
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      s24,
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(
                            maxHeight: 140.0,
                            maxWidth: 400.0,
                          ),
                          child: RepaintBoundary(
                            child: LineChart(
                              duration: Duration(milliseconds: 250),
                              LineChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  rightTitles: AxisTitles(),
                                  topTitles: AxisTitles(),
                                  bottomTitles: AxisTitles(),
                                  leftTitles: AxisTitles(),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                  border: Border.all(color: Colors.white60),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _getChartData(
                                      selectedPeriod,
                                      selectedDate,
                                      joinYear,
                                      currentWeight,
                                    ),
                                    isCurved: true,
                                    color: Colors.white,
                                    barWidth: 2,
                                    isStrokeCapRound: true,
                                    belowBarData: BarAreaData(
                                      show: false,
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                    dotData: FlDotData(show: true),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      s24,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _getChartLabels(
                          selectedPeriod,
                          selectedDate,
                          joinYear,
                        ).map((label) {
                          return Text(
                            label,
                            style: AppTextStyles.instance.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                              fontSize: selectedPeriod == 'Month' ? 11 : 14,
                            ),
                          );
                        }).toList(),
                      ),
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

class MiniTextWidget extends StatelessWidget {
  final String unitValue;
  final String unitType;
  final String unitDesc;
  const MiniTextWidget({
    super.key,
    required this.unitValue,
    required this.unitType,
    required this.unitDesc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: unitValue,
                style: AppTextStyles.instance.headline.copyWith(
                  color: AppColors.instance.onSurfaceDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: unitType,
                style: AppTextStyles.instance.titleLarge.copyWith(
                  color: AppColors.instance.onSurfaceDark,
                ),
              ),
            ],
          ),
        ),
        Text(
          unitDesc,
          style: AppTextStyles.instance.labelLarge.copyWith(
            color: AppColors.instance.onSurfaceDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
