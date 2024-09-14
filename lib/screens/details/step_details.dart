import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../utilities/step_count/step_count.dart';
import '../../utilities/export.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StepsDetails extends StatefulWidget {
  const StepsDetails({
    super.key,
  });

  @override
  State<StepsDetails> createState() => _StepsDetailsState();
}

class _StepsDetailsState extends State<StepsDetails> {
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
  void initState() {
    createInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepCountProvider = Provider.of<StepCountProvider>(context);
    dynamic yourSteps = stepCountProvider.stepCount;
    if (stepCountProvider.pedestrianStatus == 'unavailable') {
      setState(() {
        yourSteps == 1;
      });
    } else {
      setState(() {
        yourSteps == stepCountProvider.stepCount;
      });
    }
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Steps Details",
          style: theme.titleMedium,
        ),
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
                        "A) This step count is based on an average human's height or stride length. It may not be accurate for everyone.",
                        style: theme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "B) We have disabled our app to run automatically in background to count steps as it will drain battery faster.",
                        style: theme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "C) If you want to count steps even when app is not running, you will have to open app once and leave it in the background.",
                        style: theme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "D) If you want an feature to count steps even when app is terminated, email us using the in-app feedback feature or at isedenlive@gmail.com",
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
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          Text(
            "You Have To Take\nMore Steps!",
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
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                ),
                CircularPercentIndicator(
                  percent: stepCountProvider.stepCount < 10000
                      ? stepCountProvider.stepCount.toDouble() / 10000
                      : 1,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.orange.withOpacity(0.5),
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  backgroundWidth: -1,
                  radius: 115,
                  lineWidth: 15,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        stepCountProvider.pedestrianStatus == 'walking'
                            ? Icons.directions_run_rounded
                            : stepCountProvider.pedestrianStatus == 'stopped'
                                ? Icons.accessibility_new_rounded
                                : Icons.accessibility_new_rounded,
                        size: 30,
                        color: Colors.orange,
                      ),
                      Text(
                        (yourSteps).toString(),
                        style: const TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange),
                      ),
                      Text(
                        "STEPS",
                        style: theme.titleMedium,
                      ),
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
                value: ((yourSteps) * 0.05).toStringAsFixed(1) + " kcal",
                iconColor: Colors.purple,
              ),
              ActivityStats(
                icon: Icons.watch_later_outlined,
                value: ((yourSteps) * 0.015).toStringAsFixed(1) + " min",
                iconColor: Colors.green,
              ),
              ActivityStats(
                icon: Icons.location_on,
                value: (((yourSteps) * 2.4) / 3281).toStringAsFixed(2) + " km",
                iconColor: Colors.orange,
              )
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Achievements',
            style: theme.titleLarge,
          ),
          const SizedBox(height: 16),
          AchievementsWidget(
            title: 'BEGINNER',
            value: '500',
            isComplete: yourSteps > 500 ? true : false,
          ),
          AchievementsWidget(
            title: 'MR. NOBODY',
            value: '1000',
            isComplete: yourSteps > 1000 ? true : false,
          ),
          AchievementsWidget(
            title: 'THE HEALTH CONCIOUS',
            value: '10k',
            isComplete: yourSteps > 10000 ? true : false,
          ),
          AchievementsWidget(
            title: 'ATHLETE',
            value: '20k',
            isComplete: yourSteps > 20000 ? true : false,
          ),
          AchievementsWidget(
            title: 'ELITE RUNNER',
            value: '50k',
            isComplete: yourSteps > 50000 ? true : false,
          ),
          AchievementsWidget(
            title: 'MASTER',
            value: '75k',
            isComplete: yourSteps > 75000 ? true : false,
          ),
          AchievementsWidget(
            title: 'THE CONQUERER',
            value: '100k',
            isComplete: yourSteps > 100000 ? true : false,
          ),
        ],
      ),
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
        Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}
