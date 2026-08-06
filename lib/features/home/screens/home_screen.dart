import '/core/utils/exports.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '/data/adapters/weight_adapter.dart';
import '/core/services/health_service.dart';
import '/core/services/home_widget_service.dart';
import '/core/services/revenuecat_service.dart';
import '/core/widgets/custom_search_bar.dart';
import '/core/widgets/custom_route.dart';
import '/core/providers/selected_date_provider.dart';
import '/core/providers/user_provider.dart';
import '/core/providers/theme_provider.dart';

import '/features/home/screens/widgets/macros_widget.dart';
import '/features/home/screens/widgets/weight_widget.dart';
import '/features/home/screens/widgets/health_data_widget.dart';
import '/features/home/screens/widgets/water_widget.dart';
import '/features/home/screens/widgets/runner_widget.dart';
import '/features/home/screens/widgets/water_tracker_widget.dart';
import '/features/home/screens/widgets/streak_widget.dart';
import '/features/home/screens/meals_list_data.dart';
import '/features/details/screens/calorie_details.dart';
import '/features/chat/screens/chat_screen.dart';
import '/features/workouts/screens/homeworkout_card.dart';
import '/features/workouts/screens/homeworkouts_card_data.dart';
import '/features/workouts/screens/workouts_widgets/workout_videos.dart';
import '/utils/app_extensions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<MealsListData> mealsListData = MealsListData.tabIconsList;
  List<HomeWorkoutData> homeWorkoutData = HomeWorkoutData.workoutList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb) {
        HealthService().requestPermissions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final isSmall = Res.isMobile(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final u = ref.watch(userProvider);
    final init = ref.watch(userInitializationProvider);
    return Scaffold(
      body: init.when(
        loading: () => const Center(
          child: RepaintBoundary(
            child: CircularProgressIndicator(color: Colors.green),
          ),
        ),
        error: (err, stack) => Center(child: Text('Error loading user data')),
        data: (_) {
          if (u == null) {
            return const Center(
              child: RepaintBoundary(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            );
          }
          double weight = u.weight.toDouble();
          var weightBox = Hive.box<WeightTracker>('weight_tracker');
          String key =
              "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
          if (weightBox.containsKey(key)) {
            weight = weightBox.get(key)!.weight.toDouble();
          }

          double bmr = HealthCalculator.calculateBMR(u, weight);
          double tdee = HealthCalculator.calculateTDEE(bmr, u.lifestyle);
          double calories = HealthCalculator.calculateTargetCalories(
            tdee,
            u.goal,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            HomeWidgetService.saveCalories(calories);
            HomeWidgetService.updateWidgets(selectedDate);
          });

          return ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(AppConstants.defPadOuter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomRoundButton(
                          onPressed: () => Navigator.push(
                            context,
                            createRoute(
                              ChatPage(newChat: true, imageSearch: true),
                            ),
                          ),
                          size: 13,
                          child: Icon(
                            CupertinoIcons.bolt_fill,
                            size: AppConstants.defIconSize,
                          ),
                        ),
                        w12,
                        Expanded(child: CustomSearchBar()),
                      ],
                    ),
                    s24,
                    EasyDateTimeLine(
                      initialDate: selectedDate,
                      onDateChange: (newDate) {
                        ref
                            .read(selectedDateProvider.notifier)
                            .updateDate(newDate);
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
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
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
                  ],
                ),
              ),
              if (isSmall)
                WeightWidget()
              else
                Row(
                  children: [
                    w12,
                    WaterTrackerWidget(),
                    w12,
                    Expanded(child: WeightWidget()),
                    w12,
                  ],
                ),
              s24,
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.defPadOuter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreakWidget(),
                    s24,
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        createRoute(CaloriesDetails(dailycalories: calories)),
                      ),
                      child: HomeMacrosWidget(macroData: calories),
                    ),
                    s24,
                  ],
                ),
              ),
              RepaintBoundary(
                child: CustomCrouselSlider(
                  homeWorkoutData: homeWorkoutData,
                  gender: u.gender,
                ),
              ),
              s20,
              Opacity(opacity: 1, child: const RunnerWidget()),
              s24,
              if (isSmall) ...[
                WaterTrackerWidget().px(AppConstants.defPadOuter),
                s24,
              ],
              if (!kIsWeb) HealthDataWidget().px(AppConstants.defPadOuter),
              s16,
              RepaintBoundary(
                child: Stack(
                  children: [
                    SizedBox(
                      height: isSmall ? 240 : 360,
                      child: ListView.builder(
                        itemCount: mealsListData.length,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(left: isSmall ? 20 : 30),
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: isSmall ? 155 : 220,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 32,
                                    bottom: 10,
                                  ),
                                  child: Opacity(
                                    opacity: isDark ? 0.85 : 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(
                                              mealsListData[index].startColor,
                                            ),
                                            Color(
                                              mealsListData[index].endColor,
                                            ),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(8.0),
                                          bottomLeft: Radius.circular(8.0),
                                          topLeft: Radius.circular(8.0),
                                          topRight: Radius.circular(54.0),
                                        ),
                                      ),
                                      margin: EdgeInsets.only(
                                        right: isSmall ? 16 : 24,
                                      ),
                                      padding: EdgeInsets.only(
                                        top: 54,
                                        left: isSmall ? 15 : 25,
                                        right: isSmall ? 15 : 25,
                                        bottom: 6,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          if (!isSmall) SizedBox(height: 12),
                                          Text(
                                            mealsListData[index].titleTxt,
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles
                                                .instance
                                                .titleSmall
                                                .copyWith(
                                              fontSize: isSmall ? 14 : 18,
                                              color: AppColors
                                                  .instance
                                                  .onSurfaceDark,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                                bottom: 8,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    mealsListData[index].meals!
                                                        .join('\n'),
                                                    style: AppTextStyles
                                                        .instance
                                                        .body
                                                        .copyWith(
                                                      fontSize: isSmall
                                                          ? 14
                                                          : 16,
                                                      color: AppColors
                                                          .instance
                                                          .onSurfaceDark,
                                                    ),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '2000' // make it dynamic
                                                    .toString()
                                                    .split('.')
                                                    .first,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isSmall ? 20 : 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: 4,
                                                  bottom: 6,
                                                ),
                                                child: Text(
                                                  'kcal',
                                                  style: AppTextStyles
                                                      .instance
                                                      .body
                                                      .copyWith(
                                                    fontSize: isSmall
                                                        ? 14
                                                        : 16,
                                                    color: AppColors
                                                        .instance
                                                        .onSurfaceDark,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFAFAFA,
                                      ).withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 8,
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Image.asset(
                                      mealsListData[index].imagePath,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,

                              Theme.of(
                                context,
                              ).scaffoldBackgroundColor.withValues(alpha: 0.32),
                              Theme.of(
                                context,
                              ).scaffoldBackgroundColor.withValues(alpha: 0.64),
                              Theme.of(
                                context,
                              ).scaffoldBackgroundColor.withValues(alpha: 0.72),
                              Theme.of(
                                context,
                              ).scaffoldBackgroundColor.withValues(alpha: 0.64),
                              Theme.of(
                                context,
                              ).scaffoldBackgroundColor.withValues(alpha: 0.32),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.instance.surfaceDark
                                  : AppColors.instance.surface,
                              shape: BoxShape.circle,
                              boxShadow: kElevationToShadow[2],
                            ),
                            child: Icon(
                              Icons.lock,
                              size: 36,
                              color: AppColors.instance.primary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "Premium Content",
                            style: AppTextStyles.instance.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Unlock full personalized diet plans",
                            style: AppTextStyles.instance.body.copyWith(
                              // color: Colors.grey.shade500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () async {
                              final offerings = await RevenueCatService.getOfferings();

                              if (offerings == null || offerings.current == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("No offerings available")),
                                );
                                return;
                              }

                              final package = offerings.current!.availablePackages.first;

                              final result = await RevenueCatService.purchase(package);

                              if (result != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Purchase successful!")),
                                );
                              }
                            },



                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.instance.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              "Unlock Now",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              WaterDrinkWidget(),
              s24,
            ],
          );
        },
      ),
    );
  }
}

class CustomCrouselSlider extends StatelessWidget {
  const CustomCrouselSlider({
    super.key,
    required this.homeWorkoutData,
    required this.gender,
  });

  final List<HomeWorkoutData> homeWorkoutData;
  final dynamic gender;

  @override
  Widget build(BuildContext context) {
    final isSmall = Res.isMobile(context);
    return SizedBox(
      height: isSmall ? 280 : 400,
      child: CarouselSlider.builder(
        itemCount: homeWorkoutData.length,
        itemBuilder: ((context, index, realIndex) {
          return RepaintBoundary(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  createRoute(
                    HomeWorkouts(
                      genderDoc: gender.toLowerCase() == 'male'
                          ? AppStrings.maleDoc
                          : AppStrings.femaleDoc,
                      collectionName: AppStrings.pushCollectionNames[index],
                    ),
                  ),
                );
              },
              child: Opacity(
                opacity: 1,
                child: HomeworkoutCard(
                  width: MediaQuery.of(context).size.width,
                  image: gender.toLowerCase() == 'male'
                      ? homeWorkoutData[index].imageM
                      : homeWorkoutData[index].imageW,
                  cardColor: homeWorkoutData[index].cardColor,
                  title: homeWorkoutData[index].title,
                  subtitle: homeWorkoutData[index].subtitle,
                  calories: homeWorkoutData[index].calories,
                  time: homeWorkoutData[index].time,
                ),
              ),
            ),
          );
        }),
        options: CarouselOptions(
          enlargeCenterPage: true,
          height: isSmall ? 280 : 400,
        ),
      ),
    );
  }
}

class AnimatedWidget extends StatelessWidget {
  const AnimatedWidget({
    super.key,
    this.animationController,
    this.animation,
    required this.childWidget,
  });
  final Widget childWidget;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              50 * (1.0 - animation!.value),
              0.0,
            ),
            child: childWidget,
          ),
        );
      },
    );
  }
}















// import '/core/utils/exports.dart';
// import 'package:flutter/foundation.dart';
// import 'package:easy_date_timeline/easy_date_timeline.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:carousel_slider/carousel_slider.dart';
//
// import '/data/adapters/weight_adapter.dart';
// import '/core/services/health_service.dart';
// import '/core/services/home_widget_service.dart';
// import '/core/widgets/custom_search_bar.dart';
// import '/core/widgets/custom_route.dart';
// import '/core/providers/selected_date_provider.dart';
// import '/core/providers/user_provider.dart';
// import '/core/providers/theme_provider.dart';
//
// import '/features/home/screens/widgets/macros_widget.dart';
// import '/features/home/screens/widgets/weight_widget.dart';
// import '/features/home/screens/widgets/health_data_widget.dart';
// import '/features/home/screens/widgets/water_widget.dart';
// import '/features/home/screens/widgets/runner_widget.dart';
// import '/features/home/screens/widgets/water_tracker_widget.dart';
// import '/features/home/screens/widgets/streak_widget.dart';
// import '/features/home/screens/meals_list_data.dart';
// import '/features/details/screens/calorie_details.dart';
// import '/features/chat/screens/chat_screen.dart';
// import '/features/workouts/screens/homeworkout_card.dart';
// import '/features/workouts/screens/homeworkouts_card_data.dart';
// import '/features/workouts/screens/workouts_widgets/workout_videos.dart';
// import '/utils/app_extensions.dart';
//
// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   List<MealsListData> mealsListData = MealsListData.tabIconsList;
//   List<HomeWorkoutData> homeWorkoutData = HomeWorkoutData.workoutList;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!kIsWeb) {
//         HealthService().requestPermissions();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = ref.watch(themeProvider);
//     final isSmall = Res.isMobile(context);
//     final selectedDate = ref.watch(selectedDateProvider);
//     final u = ref.watch(userProvider);
//     final init = ref.watch(userInitializationProvider);
//     return Scaffold(
//       body: init.when(
//         loading: () => const Center(
//           child: RepaintBoundary(
//             child: CircularProgressIndicator(color: Colors.green),
//           ),
//         ),
//         error: (err, stack) => Center(child: Text('Error loading user data')),
//         data: (_) {
//           if (u == null) {
//             return const Center(
//               child: RepaintBoundary(
//                 child: CircularProgressIndicator(color: Colors.green),
//               ),
//             );
//           }
//           double weight = u.weight.toDouble();
//           var weightBox = Hive.box<WeightTracker>('weight_tracker');
//           String key =
//               "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
//           if (weightBox.containsKey(key)) {
//             weight = weightBox.get(key)!.weight.toDouble();
//           }
//
//           double bmr = HealthCalculator.calculateBMR(u, weight);
//           double tdee = HealthCalculator.calculateTDEE(bmr, u.lifestyle);
//           double calories = HealthCalculator.calculateTargetCalories(
//             tdee,
//             u.goal,
//           );
//
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             HomeWidgetService.saveCalories(calories);
//             HomeWidgetService.updateWidgets(selectedDate);
//           });
//
//           return ListView(
//             children: [
//               Padding(
//                 padding: EdgeInsets.all(AppConstants.defPadOuter),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         CustomRoundButton(
//                           onPressed: () => Navigator.push(
//                             context,
//                             createRoute(
//                               ChatPage(newChat: true, imageSearch: true),
//                             ),
//                           ),
//                           size: 13,
//                           child: Icon(
//                             CupertinoIcons.bolt_fill,
//                             size: AppConstants.defIconSize,
//                           ),
//                         ),
//                         w12,
//                         Expanded(child: CustomSearchBar()),
//                       ],
//                     ),
//                     s24,
//                     EasyDateTimeLine(
//                       initialDate: selectedDate,
//                       onDateChange: (newDate) {
//                         ref
//                             .read(selectedDateProvider.notifier)
//                             .updateDate(newDate);
//                       },
//                       headerProps: EasyHeaderProps(
//                         monthPickerType: MonthPickerType.switcher,
//                         dateFormatter: const DateFormatter.fullDateDMY(),
//                         monthStyle: TextStyle(
//                           color: isDark ? Colors.white : Colors.black87,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         selectedDateStyle: TextStyle(
//                           color: isDark ? Colors.white : Colors.black87,
//                         ),
//                       ),
//                       dayProps: EasyDayProps(
//                         dayStructure: DayStructure.dayStrDayNum,
//                         activeDayStyle: DayStyle(
//                           dayNumStyle: TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           dayStrStyle: TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: const BorderRadius.all(
//                               Radius.circular(8),
//                             ),
//                             color: AppColors.instance.primary,
//                           ),
//                         ),
//                         inactiveDayStyle: DayStyle(
//                           dayNumStyle: TextStyle(
//                             color: isDark ? Colors.white70 : Colors.black87,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           dayStrStyle: TextStyle(
//                             color: isDark ? Colors.white54 : Colors.black54,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (isSmall)
//                 WeightWidget()
//               else
//                 Row(
//                   children: [
//                     w12,
//                     WaterTrackerWidget(),
//                     w12,
//                     Expanded(child: WeightWidget()),
//                     w12,
//                   ],
//                 ),
//               s24,
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: AppConstants.defPadOuter,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     StreakWidget(),
//                     s24,
//                     GestureDetector(
//                       onTap: () => Navigator.push(
//                         context,
//                         createRoute(CaloriesDetails(dailycalories: calories)),
//                       ),
//                       child: HomeMacrosWidget(macroData: calories),
//                     ),
//                     s24,
//                   ],
//                 ),
//               ),
//               RepaintBoundary(
//                 child: CustomCrouselSlider(
//                   homeWorkoutData: homeWorkoutData,
//                   gender: u.gender,
//                 ),
//               ),
//               s20,
//               Opacity(opacity: 1, child: const RunnerWidget()),
//               s24,
//               if (isSmall) ...[
//                 WaterTrackerWidget().px(AppConstants.defPadOuter),
//                 s24,
//               ],
//               if (!kIsWeb) HealthDataWidget().px(AppConstants.defPadOuter),
//               s16,
//               RepaintBoundary(
//                 child: Stack(
//                   children: [
//                     SizedBox(
//                       height: isSmall ? 240 : 360,
//                       child: ListView.builder(
//                         itemCount: mealsListData.length,
//                         scrollDirection: Axis.horizontal,
//                         padding: EdgeInsets.only(left: isSmall ? 20 : 30),
//                         itemBuilder: (BuildContext context, int index) {
//                           return SizedBox(
//                             width: isSmall ? 155 : 220,
//                             child: Stack(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                     top: 32,
//                                     bottom: 10,
//                                   ),
//                                   child: Opacity(
//                                     opacity: isDark ? 0.85 : 1,
//                                     child: Container(
//                                       decoration: BoxDecoration(
//                                         gradient: LinearGradient(
//                                           colors: [
//                                             Color(
//                                               mealsListData[index].startColor,
//                                             ),
//                                             Color(
//                                               mealsListData[index].endColor,
//                                             ),
//                                           ],
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                         ),
//                                         borderRadius: const BorderRadius.only(
//                                           bottomRight: Radius.circular(8.0),
//                                           bottomLeft: Radius.circular(8.0),
//                                           topLeft: Radius.circular(8.0),
//                                           topRight: Radius.circular(54.0),
//                                         ),
//                                       ),
//                                       margin: EdgeInsets.only(
//                                         right: isSmall ? 16 : 24,
//                                       ),
//                                       padding: EdgeInsets.only(
//                                         top: 54,
//                                         left: isSmall ? 15 : 25,
//                                         right: isSmall ? 15 : 25,
//                                         bottom: 6,
//                                       ),
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           if (!isSmall) SizedBox(height: 12),
//                                           Text(
//                                             mealsListData[index].titleTxt,
//                                             textAlign: TextAlign.center,
//                                             style: AppTextStyles
//                                                 .instance
//                                                 .titleSmall
//                                                 .copyWith(
//                                                   fontSize: isSmall ? 14 : 18,
//                                                   color: AppColors
//                                                       .instance
//                                                       .onSurfaceDark,
//                                                 ),
//                                           ),
//                                           Expanded(
//                                             child: Padding(
//                                               padding: const EdgeInsets.only(
//                                                 top: 8,
//                                                 bottom: 8,
//                                               ),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.start,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     mealsListData[index].meals!
//                                                         .join('\n'),
//                                                     style: AppTextStyles
//                                                         .instance
//                                                         .body
//                                                         .copyWith(
//                                                           fontSize: isSmall
//                                                               ? 14
//                                                               : 16,
//                                                           color: AppColors
//                                                               .instance
//                                                               .onSurfaceDark,
//                                                         ),
//                                                     overflow: TextOverflow.fade,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.end,
//                                             children: [
//                                               Text(
//                                                 '2000' // make it dynamic
//                                                     .toString()
//                                                     .split('.')
//                                                     .first,
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: isSmall ? 20 : 24,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               Padding(
//                                                 padding: EdgeInsets.only(
//                                                   left: 4,
//                                                   bottom: 6,
//                                                 ),
//                                                 child: Text(
//                                                   'kcal',
//                                                   style: AppTextStyles
//                                                       .instance
//                                                       .body
//                                                       .copyWith(
//                                                         fontSize: isSmall
//                                                             ? 14
//                                                             : 16,
//                                                         color: AppColors
//                                                             .instance
//                                                             .onSurfaceDark,
//                                                       ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   top: 0,
//                                   left: 0,
//                                   child: Container(
//                                     width: 84,
//                                     height: 84,
//                                     decoration: BoxDecoration(
//                                       color: const Color(
//                                         0xFFFAFAFA,
//                                       ).withValues(alpha: 0.2),
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   top: 0,
//                                   left: 8,
//                                   child: SizedBox(
//                                     width: 80,
//                                     height: 80,
//                                     child: Image.asset(
//                                       mealsListData[index].imagePath,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     Positioned.fill(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.transparent,
//
//                               Theme.of(
//                                 context,
//                               ).scaffoldBackgroundColor.withValues(alpha: 0.32),
//                               Theme.of(
//                                 context,
//                               ).scaffoldBackgroundColor.withValues(alpha: 0.64),
//                               Theme.of(
//                                 context,
//                               ).scaffoldBackgroundColor.withValues(alpha: 0.72),
//                               Theme.of(
//                                 context,
//                               ).scaffoldBackgroundColor.withValues(alpha: 0.64),
//                               Theme.of(
//                                 context,
//                               ).scaffoldBackgroundColor.withValues(alpha: 0.32),
//                               Colors.transparent,
//                             ],
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned.fill(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(15),
//                             decoration: BoxDecoration(
//                               color: isDark
//                                   ? AppColors.instance.surfaceDark
//                                   : AppColors.instance.surface,
//                               shape: BoxShape.circle,
//                               boxShadow: kElevationToShadow[2],
//                             ),
//                             child: Icon(
//                               Icons.lock,
//                               size: 36,
//                               color: AppColors.instance.primary,
//                             ),
//                           ),
//                           const SizedBox(height: 14),
//                           Text(
//                             "Premium Content",
//                             style: AppTextStyles.instance.titleLarge.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 5),
//                           Text(
//                             "Unlock full personalized diet plans",
//                             style: AppTextStyles.instance.body.copyWith(
//                               // color: Colors.grey.shade500,
//                               fontSize: 15,
//                             ),
//                           ),
//                           const SizedBox(height: 14),
//                           ElevatedButton(
//                             onPressed: () {},
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.instance.primary,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(24),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 40,
//                                 vertical: 14,
//                               ),
//                               elevation: 2,
//                             ),
//                             child: const Text(
//                               "Unlock Now",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               WaterDrinkWidget(),
//               s24,
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
//
// class CustomCrouselSlider extends StatelessWidget {
//   const CustomCrouselSlider({
//     super.key,
//     required this.homeWorkoutData,
//     required this.gender,
//   });
//
//   final List<HomeWorkoutData> homeWorkoutData;
//   final dynamic gender;
//
//   @override
//   Widget build(BuildContext context) {
//     final isSmall = Res.isMobile(context);
//     return SizedBox(
//       height: isSmall ? 280 : 400,
//       child: CarouselSlider.builder(
//         itemCount: homeWorkoutData.length,
//         itemBuilder: ((context, index, realIndex) {
//           return RepaintBoundary(
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   createRoute(
//                     HomeWorkouts(
//                       genderDoc: gender.toLowerCase() == 'male'
//                           ? AppStrings.maleDoc
//                           : AppStrings.femaleDoc,
//                       collectionName: AppStrings.pushCollectionNames[index],
//                     ),
//                   ),
//                 );
//               },
//               child: Opacity(
//                 opacity: 1,
//                 child: HomeworkoutCard(
//                   width: MediaQuery.of(context).size.width,
//                   image: gender.toLowerCase() == 'male'
//                       ? homeWorkoutData[index].imageM
//                       : homeWorkoutData[index].imageW,
//                   cardColor: homeWorkoutData[index].cardColor,
//                   title: homeWorkoutData[index].title,
//                   subtitle: homeWorkoutData[index].subtitle,
//                   calories: homeWorkoutData[index].calories,
//                   time: homeWorkoutData[index].time,
//                 ),
//               ),
//             ),
//           );
//         }),
//         options: CarouselOptions(
//           enlargeCenterPage: true,
//           height: isSmall ? 280 : 400,
//         ),
//       ),
//     );
//   }
// }
//
// class AnimatedWidget extends StatelessWidget {
//   const AnimatedWidget({
//     super.key,
//     this.animationController,
//     this.animation,
//     required this.childWidget,
//   });
//   final Widget childWidget;
//   final AnimationController? animationController;
//   final Animation<double>? animation;
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: animationController!,
//       builder: (BuildContext context, Widget? child) {
//         return FadeTransition(
//           opacity: animation!,
//           child: Transform(
//             transform: Matrix4.translationValues(
//               0.0,
//               50 * (1.0 - animation!.value),
//               0.0,
//             ),
//             child: childWidget,
//           ),
//         );
//       },
//     );
//   }
// }
