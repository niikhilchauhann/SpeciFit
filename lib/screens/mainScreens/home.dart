import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:specifit/screens/details/calorie_details.dart';
import 'package:specifit/screens/details/step_details.dart';
import '../../helpers/meals_list_data.dart';
import '../../utilities/export.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../utilities/step_count/step_count.dart';
import 'account.dart';
import 'workouts/workout_videos.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final BannerAd bannerAdUnit = BannerAd(
    adUnitId: AdService.adUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: AdService.bannerAdListener,
  )..load();
  final BannerAd bannerAdUnit1 = BannerAd(
    adUnitId: AdService.adUnitId,
    size: AdSize.mediumRectangle,
    request: const AdRequest(),
    listener: AdService.bannerAdListener,
  )..load();
  int _currentIntake = 0;

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentIntake = prefs.getInt('currentIntake') ?? 0;
    });
  }

  _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('currentIntake', _currentIntake);
  }

  void _incrementIntake() {
    setState(() {
      _currentIntake += 250;
    });
    _saveData();
  }

  void _decrementIntake() {
    setState(() {
      _currentIntake -= 250;
      if (_currentIntake < 0) {
        _currentIntake = 0;
      }
    });
    _saveData();
  }

  void _resetIntake() {
    setState(() {
      _currentIntake = 0;
    });
    _saveData();
  }

  List<MealsListData> mealsListData = MealsListData.tabIconsList;
  List<HomeWorkoutData> homeWorkoutData = HomeWorkoutData.workoutList;

  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  dynamic userData;
  bool isDataLoaded = false;
  Future getData() async {
    var document = db.collection('users').doc(user!.uid);
    document.get().then(
      (document) async {
        userData = document;
        isDataLoaded = true;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          firstname = userData['firstname'];
          gender = userData['gender'];
          height = userData['height'];
          weight = userData['weight'];
          age = userData['age'];
          goal = userData['goal'];
          level = userData['level'];
          lifestyle = userData['lifestyle'];
          prefs.setString('userGender', userData['gender']);
          prefs.setString('userLevel', userData['level']);
        });
      },
    );
  }

  dynamic firstname;
  dynamic gender;
  dynamic height;
  dynamic weight;
  dynamic age;
  dynamic goal;
  dynamic level;
  dynamic lifestyle;
  dynamic bmr;
  dynamic tdee;
  dynamic calories;

  InterstitialAd? _interstitialAd;
  createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdService.adUnitIdInterstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {},
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getData();
    createInterstitialAd();
    _loadData();
    super.initState();
  }

  bool isDarkMode(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var theme = Theme.of(context).textTheme;
    if (isDataLoaded == true) {
      // if (kDebugMode) {
      //   print(
      //       'USERDATA: $firstname $gender $height $weight $age $goal $level $lifestyle $tdee $calories');
      // }
      if (gender.toLowerCase() == 'male') {
        bmr = 10 * weight + 6.25 * height - 5 * age + 5;
      } else {
        bmr = 10 * weight + 6.25 * height - 5 * age - 161;
      }

      switch (lifestyle) {
        case 'Sedentary':
          tdee = bmr * 1.2;
          break;
        case 'Lightly active':
          tdee = bmr * 1.375;
          break;
        case 'Moderately active':
          tdee = bmr * 1.55;
          break;
        case 'Very active':
          tdee = bmr * 1.725;
          break;
        case 'Extremely active':
          tdee = bmr * 1.9;
          break;
        default:
          tdee = bmr * 1.55;
      }
      switch (goal.toLowerCase().split(' ').first) {
        case 'lose':
          calories = tdee - 500;
          break;
        case 'gain':
          calories = tdee + 500;
          break;
        case 'maintain':
          calories = tdee;
          break;
        default:
      }

      List food = [
        calories / 3.6,
        calories / 3.8,
        calories / 4.2,
        calories / 4.4
      ];

      List<Widget> widgets = [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              createRoute(
                const StepsDetails(),
              ),
            );
          },
          child: Opacity(
            opacity: isDarkMode(context) ? 0.85 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    stepscolor,
                    const Color(0xFFFF8C8C),
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: kElevationToShadow[3],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<StepCountProvider>(
                    builder: (_, provider, __) => CardTitle(
                      title: "Step",
                      icon: provider.pedestrianStatus == 'walking'
                          ? Icons.directions_run_rounded
                          : provider.pedestrianStatus == 'stopped'
                              ? Icons.accessibility_new_rounded
                              : Icons.accessibility_new_rounded,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Consumer<StepCountProvider>(
                        builder: (_, provider, __) => Text(
                          provider.stepCount.toString(),
                          style: h2white,
                        ),
                      ),
                      const Text(
                        " Steps",
                        style: medium,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              createRoute(
                CaloriesDetails(dailycalories: calories),
              ),
            );
          },
          child: Opacity(
            opacity: isDarkMode(context) ? 0.85 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    caloriescolor,
                    const Color(0xFFFFC685),
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: kElevationToShadow[3],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardTitle(
                    title: "Calories",
                    icon: CupertinoIcons.flame_fill,
                    size: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        calories.toString().split('.').first,
                        style: h2white,
                      ),
                      const Text(
                        " Kcal",
                        style: medium,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Opacity(
          opacity: isDarkMode(context) ? 0.85 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  statscolor,
                  const Color(0xFF8496FF),
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              boxShadow: kElevationToShadow[3],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardTitle(
                  title: "Weight",
                  icon: Icons.bar_chart,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          weight.toString(),
                          style: h2white,
                        ),
                        const Text(
                          " Kg",
                          style: medium,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Opacity(
          opacity: isDarkMode(context) ? 0.85 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [watercolor, const Color(0xFF82D4E4)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: kElevationToShadow[3],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardTitle(
                      title: "Water",
                      icon: CupertinoIcons.drop_fill,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$_currentIntake",
                          style: h2white,
                        ),
                        const Text(" Ml", style: medium),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WaterButton(
                        ontap: _incrementIntake,
                        icon: CupertinoIcons.add,
                      ),
                      WaterButton(
                        ontap: _decrementIntake,
                        icon: CupertinoIcons.minus,
                      ),
                      WaterButton(
                        ontap: _resetIntake,
                        icon: Icons.refresh,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ];

      return WillPopScope(
        onWillPop: () => exitDialogue(() => _interstitialAd!.show(), context),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    createRoute(
                                      Account(
                                        userdata: userData,
                                        image: gender.toLowerCase() == 'male'
                                            ? "https://firebasestorage.googleapis.com/v0/b/edco-specifit.appspot.com/o/m.jpg?alt=media&token=5b5cd361-0d20-45d7-81a4-c912a766e28f"
                                            : "https://firebasestorage.googleapis.com/v0/b/edco-specifit.appspot.com/o/w.jpg?alt=media&token=d2272a73-d8a0-4b3e-ad7e-75778641695d",
                                      ),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor: primary,
                                  foregroundImage: CachedNetworkImageProvider(
                                    gender.toLowerCase() == 'male'
                                        ? "https://firebasestorage.googleapis.com/v0/b/edco-specifit.appspot.com/o/m.jpg?alt=media&token=5b5cd361-0d20-45d7-81a4-c912a766e28f"
                                        : "https://firebasestorage.googleapis.com/v0/b/edco-specifit.appspot.com/o/w.jpg?alt=media&token=d2272a73-d8a0-4b3e-ad7e-75778641695d",
                                  ),
                                  radius: 24,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Hey ${firstname.split(' ').first} 👋",
                                      style: theme.headlineSmall),
                                  Text(
                                      DateFormat.MMMEd().format(DateTime.now()),
                                      style: theme.labelLarge),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(18)),
                            child: const CustomPopupMenu(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const SearchWorkouts();
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(38),
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                  offset: const Offset(0, 2),
                                  blurRadius: 8.0),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.search,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Search any workout...",
                                style: theme.labelLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Activity",
                            style: theme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          AspectRatio(
                            aspectRatio: 1.2,
                            child: GridView(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 15,
                                      crossAxisSpacing: 15,
                                      childAspectRatio: 1.25),
                              children: List.generate(
                                4,
                                (int index) {
                                  return widgets[index];
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Workouts Videos",
                        style: theme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // SizedBox(
                    //     height: 240,
                    //     child: CarouselSlider.builder(
                    //       itemCount: homeWorkoutData.length,
                    //       itemBuilder: ((context, index, realIndex) {
                    //         String maleDoc = 'HomeWorkoutVidsM';
                    //         String femaleDoc = 'HomeWorkoutVidsW';
                    //         List pushCollectionName = [
                    //           'NoEquip',
                    //           'ResistanceBand',
                    //           'Dumbbell',
                    //           'Yoga',
                    //           'Stretching',
                    //           'Hiit',
                    //           'WeightLoss'
                    //         ];
                    //         return GestureDetector(
                    //           onTap: () {
                    //             Navigator.push(
                    //               context,
                    //               createRoute(
                    //                 HomeWorkouts(
                    //                   genderDoc: gender.toLowerCase() == 'male'
                    //                       ? maleDoc
                    //                       : femaleDoc,
                    //                   collectionName: pushCollectionName[index],
                    //                 ),
                    //               ),
                    //             );
                    //           },
                    //           child: Opacity(
                    //             opacity: isDarkMode(context) ? 0.85 : 1,
                    //             child: HomeworkoutCard(
                    //               width: width,
                    //               image: gender.toLowerCase() == 'male'
                    //                   ? homeWorkoutData[index].imageM
                    //                   : homeWorkoutData[index].imageW,
                    //               cardColor: homeWorkoutData[index].cardColor,
                    //               title: homeWorkoutData[index].title,
                    //               subtitle: homeWorkoutData[index].subtitle,
                    //               calories: homeWorkoutData[index].calories,
                    //               time: homeWorkoutData[index].time,
                    //             ),
                    //           ),
                    //         );
                    //       }),
                    //       options: CarouselOptions(
                    //         enlargeCenterPage: true,
                    //         aspectRatio: 1.85,
                    //       ),
                    //     )),
                    const SizedBox(height: 15),
                    Opacity(
                        opacity: isDarkMode(context) ? 0.85 : 1,
                        child: const RunnerWidget()),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Today's Meals",
                        style: theme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        itemCount: mealsListData.length,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20),
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            width: 155,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 32, bottom: 15),
                                  child: Opacity(
                                    opacity: isDarkMode(context) ? 0.85 : 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color(mealsListData[index]
                                                      .endColor)
                                                  .withOpacity(0.6),
                                              offset: const Offset(1.1, 4.0),
                                              blurRadius: 8.0),
                                        ],
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(mealsListData[index]
                                                .startColor),
                                            Color(
                                                mealsListData[index].endColor),
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
                                      margin: const EdgeInsets.only(right: 16),
                                      padding: const EdgeInsets.only(
                                          top: 54,
                                          left: 15,
                                          right: 15,
                                          bottom: 6),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(mealsListData[index].titleTxt,
                                              textAlign: TextAlign.center,
                                              style: h3white),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, bottom: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    mealsListData[index]
                                                        .meals!
                                                        .join('\n'),
                                                    style: medium,
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
                                                food[index]
                                                    .toString()
                                                    .split('.')
                                                    .first,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 4, bottom: 6),
                                                child:
                                                    Text('kcal', style: medium),
                                              ),
                                            ],
                                          )
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
                                      color: const Color(0xFFFAFAFA)
                                          .withOpacity(0.2),
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
                                        mealsListData[index].imagePath),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: width,
                      child: AdWidget(ad: bannerAdUnit),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Macros",
                      style: theme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 30),
                      height: 185,
                      width: width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: isDarkMode(context)
                            ? Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant)
                            : null,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                            topRight: Radius.circular(68)),
                        boxShadow: kElevationToShadow[3],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  'Calories: ${calories.toString().split('.').first}',
                                  style: theme.titleMedium),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: carbscolor),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Carbs: ${((calories * 0.55) / 4).toString().split('.').first} g",
                                    style: theme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: proteincolor),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Protein: ${((calories * 0.20) / 4).toString().split('.').first} g",
                                    style: theme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: fatcolor),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Fat: ${((calories * 0.25) / 9).toString().split('.').first} g",
                                    style: theme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 25),
                          // Expanded(
                          //   child: PieChart(
                          //     PieChartData(
                          //       startDegreeOffset: 60,
                          //       pieTouchData: PieTouchData(
                          //         touchCallback:
                          //             (FlTouchEvent event, pieTouchResponse) {
                          //           setState(
                          //             () {
                          //               if (!event
                          //                       .isInterestedForInteractions ||
                          //                   pieTouchResponse == null ||
                          //                   pieTouchResponse.touchedSection ==
                          //                       null) {
                          //                 touchedIndex = -1;
                          //                 return;
                          //               }
                          //               touchedIndex = pieTouchResponse
                          //                   .touchedSection!
                          //                   .touchedSectionIndex;
                          //             },
                          //           );
                          //         },
                          //       ),
                          //       sectionsSpace: 5,
                          //       centerSpaceRadius: 28,
                          //       sections: showingSections(),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const WaterDrinkWidget(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Want Access To 1350+ Exercises, 4500+ Diet Plans, Customized Workouts & More?',
                  style: theme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CupertinoButton.filled(
                      child: const Text('Go Premium'), onPressed: () {})),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                width: width,
                child: AdWidget(ad: bannerAdUnit1),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(color: primary),
      );
    }
  }
}

class AnimatedWidget extends StatelessWidget {
  const AnimatedWidget(
      {Key? key,
      this.animationController,
      this.animation,
      required this.childWidget})
      : super(key: key);
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
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: childWidget,
          ),
        );
      },
    );
  }
}
