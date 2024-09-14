import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../helpers/adapters/meal_adapter.dart';
import '../../utilities/export.dart';

class CaloriesDetails extends StatefulWidget {
  final dynamic dailycalories;
  const CaloriesDetails({super.key, required this.dailycalories});

  @override
  State<CaloriesDetails> createState() => _CaloriesDetailsState();
}

class _CaloriesDetailsState extends State<CaloriesDetails> {
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

  late Box<Calories> caloriesBox;
  Map<DateTime, int> _caloriesMap = {};
  late DateTime _selectedDate;

  void _updateTotals(DateTime date) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (int i = 0; i < caloriesBox.length; i++) {
      Calories calories = caloriesBox.getAt(i)!;
      if (calories.date == date) {
        totalCalories += calories.calories;
        totalProtein += calories.protein;
        totalCarbs += calories.carbohydrates;
        totalFat += calories.fat;
      }
    }

    setState(() {
      _totalCalories = totalCalories;
      _totalProtein = totalProtein;
      _totalCarbs = totalCarbs;
      _totalFat = totalFat;
    });
  }

  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalCarbs = 0;
  double _totalFat = 0;

  @override
  void initState() {
    super.initState();
    caloriesBox = Hive.box<Calories>('calories');
    _selectedDate = DateTime.now();
    _loadCalories();

    createInterstitialAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectDate(context);
    });
    // _updateTotals(_selectedDate);
  }

  void _loadCalories() {
    setState(() {
      _caloriesMap = {};
      for (int i = 0; i < caloriesBox.length; i++) {
        Calories calories = caloriesBox.getAt(i)!;
        _caloriesMap[calories.date] = calories.calories.toInt();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 182)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _updateTotals(picked);
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _updateTotals(_selectedDate);
    var carbs = ((widget.dailycalories * 0.55) / 4);
    var protein = ((widget.dailycalories * 0.20) / 4);
    var fat = ((widget.dailycalories * 0.25) / 9);
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Calories Details",
          style: theme.titleMedium,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Points to remember:",
                        style: theme.labelLarge,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "A) You must exercise at least 5-6 days a week for 45-120 minutes on average.",
                        style: theme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "B) A healthy rate of weight gain or loss is 0.5kg/week; you can inc or dec your calories as required, but DON'T EXCEED the maximum recommended rate of 1kg/week.",
                        style: theme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "C) If you are losing or gaining weight too quickly, you should:",
                        style: theme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Increase or decrease your daily calorie intake by 100-150.",
                        style: theme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "D) If you are not losing or gaining weight or are doing so too slowly, you should:",
                        style: theme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Decrease or increase your daily calorie intake by 150-200.",
                        style: theme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  btnOkOnPress: () {
                    _interstitialAd!.show();
                  },
                  btnOkText: "OKAY",
                ).show();
              },
              icon: const Icon(
                CupertinoIcons.question_circle,
                size: 24,
              ),
            ),
          )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          iconSize: 20,
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          Text(
            "Keep Going!",
            style: theme.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "You Have To Eat\nMore Food!",
            style: theme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 225,
                  decoration: BoxDecoration(
                    color: caloriescolor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: caloriescolor.withOpacity(0.3),
                    ),
                  ),
                ),
                CircularPercentIndicator(
                  percent: _totalCalories < widget.dailycalories
                      ? (_totalCalories / widget.dailycalories).toDouble()
                      : 1,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: caloriescolor.withOpacity(0.5),
                  backgroundColor: caloriescolor.withOpacity(0.2),
                  backgroundWidth: -1,
                  radius: 100,
                  lineWidth: 15,
                  animation: true,
                  animationDuration: 800,
                  center: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          CupertinoIcons.flame_fill,
                          size: 30,
                          color: caloriescolor,
                        ),
                        Text(
                          _totalCalories.toStringAsFixed(0),
                          style: theme.headlineSmall,
                        ),
                        Text(
                          "Calories",
                          style: theme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "Macros Today",
            style: theme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MacroProgress(
                      macroname: "Carbs",
                      macrovalue: carbs,
                      macropercent: (_totalCarbs / carbs) * 100,
                      macrocolor: carbscolor),
                ),
                const SizedBox(width: 25),
                Expanded(
                  child: MacroProgress(
                      macroname: "Protein",
                      macrovalue: protein,
                      macropercent: (_totalProtein / protein) * 100,
                      macrocolor: proteincolor),
                ),
                const SizedBox(width: 25),
                Expanded(
                  child: MacroProgress(
                      macroname: "Fat",
                      macrovalue: fat,
                      macropercent: (_totalFat / fat) * 100,
                      macrocolor: fatcolor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class MacroProgress extends StatelessWidget {
  const MacroProgress({
    super.key,
    required this.macroname,
    required this.macrovalue,
    required this.macropercent,
    required this.macrocolor,
  });
  final String macroname;
  final dynamic macrovalue;
  final dynamic macropercent;
  final dynamic macrocolor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          macroname,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${macrovalue.toStringAsFixed(0)} g",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              '${(macropercent).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: macropercent < 100 ? macropercent / 100 : 1,
            minHeight: 5,
            color: macrocolor,
            backgroundColor: macrocolor.withOpacity(0.2),
          ),
        )
      ],
    );
  }
}
