import '/core/utils/exports.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '/core/providers/theme_provider.dart';
import '/core/providers/selected_date_provider.dart';
import '/core/providers/health_data_provider.dart';

import '/features/details/screens/sleep_details.dart';
import '/features/details/screens/step_details.dart';
import '/core/widgets/custom_route.dart';

class HealthDataWidget extends ConsumerStatefulWidget {
  const HealthDataWidget({super.key});

  @override
  ConsumerState<HealthDataWidget> createState() => _HealthDataWidgetState();
}

class _HealthDataWidgetState extends ConsumerState<HealthDataWidget> {
  @override
  Widget build(BuildContext context) {
    bool isDark = ref.watch(themeProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final healthDataAsync = ref.watch(healthDataProvider(selectedDate));

    return healthDataAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading health data')),
      data: (healthData) {
        final steps = healthData.steps;
        final sleepHours = healthData.sleepHours;
        final weeklySleep = healthData.weeklySleep;

        return GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: .78,
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            final fields = ['Walk', 'Sleep'];
            final icons = [Icons.directions_walk, Icons.dark_mode];
            final data = ['$steps', sleepHours.toStringAsFixed(1)];
            final subdata = ['Steps', 'Hours'];
            final List<Widget> charts = [
              SizedBox(),
              AspectRatio(
                aspectRatio: 1.68,
                child: SleepCycleChart(
                  weeklySleep: weeklySleep,
                  selectedDate: selectedDate,
                ),
              ),
            ];
            return index == 0
                ? GestureDetector(
                    onTap: () =>
                        Navigator.push(context, createRoute(StepsDetails())),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.defPadInner,
                        vertical: AppConstants.defPadOuter,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.instance.surfaceDark
                            : AppColors.instance.surface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defRadOuter,
                        ),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: isDark
                                      ? AppColors.instance.onSurfaceDark
                                      : AppColors.instance.onSurface,
                                ),
                              ),
                              Icon(
                                Icons.directions_run_rounded,
                                color: isDark
                                    ? AppColors.instance.onSurfaceDark
                                    : Colors.black38,
                                size: AppConstants.defIconSize,
                              ),
                            ],
                          ),
                          Spacer(),
                          Spacer(),
                          Center(
                            child: CircularPercentIndicator(
                              radius: 64,
                              percent: steps < 10000
                                  ? steps.toDouble() / 10000
                                  : 1,
                              progressColor: AppColors.instance.primary,
                              backgroundColor: isDark
                                  ? AppColors.instance.backgroundDark
                                  : AppColors.instance.background,
                              animation: true,
                              lineWidth: 10,
                              circularStrokeCap: CircularStrokeCap.round,
                              center: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    steps.toString(),
                                    style: AppTextStyles.instance.titleLarge
                                        .copyWith(
                                          fontSize: 24,
                                          fontWeight: FontWeight.normal,
                                          color: isDark
                                              ? AppColors.instance.onSurfaceDark
                                              : AppColors.instance.onSurface,
                                          height: 1,
                                        ),
                                  ),
                                  Text(
                                    subdata[index],
                                    style: AppTextStyles.instance.bodyLarge
                                        .copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w100,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black38,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      createRoute(const SleepDetails()),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.defPadInner,
                        vertical: AppConstants.defPadOuter,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.instance.surfaceDark
                            : AppColors.instance.surface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defRadOuter,
                        ),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: isDark
                                      ? AppColors.instance.onSurfaceDark
                                      : AppColors.instance.onSurface,
                                ),
                              ),
                              Icon(
                                icons[index],
                                color: isDark
                                    ? AppColors.instance.onSurfaceDark
                                    : Colors.black38,
                                size: AppConstants.defIconSize,
                              ),
                            ],
                          ),
                          Spacer(),
                          charts[index],
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[index],
                                style: AppTextStyles.instance.titleLarge
                                    .copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.normal,
                                      color: isDark
                                          ? AppColors.instance.onSurfaceDark
                                          : AppColors.instance.onSurface,
                                      height: 1,
                                    ),
                              ),
                              Text(
                                subdata[index],
                                style: AppTextStyles.instance.bodyLarge
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w100,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black38,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
          },
        );
      },
    );
  }
}

class SleepCycleChart extends ConsumerWidget {
  final List<double> weeklySleep;
  final DateTime selectedDate;

  const SleepCycleChart({
    super.key,
    required this.weeklySleep,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = ref.watch(themeProvider);
    return BarChart(
      BarChartData(
        barGroups: _getBarGroups(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? Colors.white54 : Colors.black54,
                );

                DateTime current = selectedDate.subtract(
                  Duration(days: 6 - value.toInt()),
                );
                String label = [
                  "M",
                  "T",
                  "W",
                  "T",
                  "F",
                  "S",
                  "S",
                ][current.weekday - 1];

                return SideTitleWidget(
                  meta: meta,
                  child: Text(label, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklySleep[index],
            color: AppColors.instance.primary,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}
