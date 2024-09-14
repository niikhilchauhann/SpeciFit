import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:specifit/screens/trackers/workout_tracker.dart';
import '../../helpers/models/exercise_model.dart';
import '../../utilities/export.dart';
import 'workouts/man_workouts.dart';
import 'workouts/startworkout.dart';
import 'workouts/woman_workouts.dart';

class Workouts extends StatefulWidget {
  const Workouts({super.key});

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  late Future<SharedPreferences> _prefs;

  Future<String?> getGender() async {
    final prefs = await _prefs;
    return prefs.getString('userGender');
  }

  Future<String?> getLevel() async {
    final prefs = await _prefs;
    return prefs.getString('userLevel');
  }

  List<Exercise> chestExercises = [];
  List<Exercise> backExercises = [];
  List<Exercise> shoulderExercises = [];
  List<Exercise> armExercises = [];
  List<Exercise> legsExercises = [];
  List<Exercise> absExercises = [];

  List<Exercise> chestExercises1 = [];
  List<Exercise> backExercises1 = [];
  List<Exercise> armExercises1 = [];
  List<Exercise> legsExercises1 = [];
  List<Exercise> absExercises1 = [];

  List<Exercise> chestExercises2 = [];
  List<Exercise> backExercises2 = [];
  List<Exercise> armExercises2 = [];
  List<Exercise> legsExercises2 = [];
  List<Exercise> absExercises2 = [];

  loadData() async {
    final jsonString = await rootBundle.loadString('assets/exercise.json');
    Map<String, dynamic> data = json.decode(jsonString);
    ExerciseData exerciseData = ExerciseData.fromJson(data);
    setState(() {
      chestExercises = exerciseData.chest;
      backExercises = exerciseData.back;
      shoulderExercises = exerciseData.shoulders;
      armExercises = exerciseData.arms;
      legsExercises = exerciseData.legs;
      absExercises = exerciseData.abs;

      chestExercises1 = exerciseData.chest1;
      backExercises1 = exerciseData.back1;
      armExercises1 = exerciseData.arms1;
      legsExercises1 = exerciseData.legs1;
      absExercises1 = exerciseData.abs1;

      chestExercises2 = exerciseData.chest2;
      backExercises2 = exerciseData.back2;
      armExercises2 = exerciseData.arms2;
      legsExercises2 = exerciseData.legs2;
      absExercises2 = exerciseData.abs2;
    });
  }

  final BannerAd bannerAdUnit = BannerAd(
    adUnitId: AdService.adUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: AdService.bannerAdListener,
  )..load();

  final BannerAd onExitAdUnit = BannerAd(
    adUnitId: AdService.adUnitId,
    size: AdSize.mediumRectangle,
    request: const AdRequest(),
    listener: AdService.bannerAdListener,
  )..load();

  final ScrollController _scrollController = ScrollController();

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
    super.initState();
    createInterstitialAd();
    _prefs = SharedPreferences.getInstance();
    loadData();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () => exitDialogue(() => _interstitialAd!.show(), context),
      child: FutureBuilder(
          future: Future.wait([getGender(), getLevel()]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String gender = snapshot.data![0]!;
              String level = snapshot.data![1]!;
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text("Workouts"),
                  actions: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(32.0),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            createRoute(
                              WorkoutCalendarScreen(level: level),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.track_changes,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8)
                  ],
                ),
                body: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: NestedScrollView(
                            controller: _scrollController,
                            headerSliverBuilder: (BuildContext context,
                                bool innerBoxIsScrolled) {
                              return [
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: SizedBox(
                                            height: 52,
                                            width: width,
                                            child: AdWidget(ad: bannerAdUnit)),
                                      );
                                    },
                                    childCount: 1,
                                  ),
                                ),
                              ];
                            },
                            body: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: ListView(
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  const SizedBox(height: 10),
                                  BodyPart(
                                    image: gender == 'Male'
                                        ? "assets/man/chest.jpg"
                                        : "assets/woman/chest.jpg",
                                    muscle: 'Chest',
                                    level: '$level:',
                                    workoutList: level == 'Beginner'
                                        ? chestExercises
                                        : level == 'Intermediate'
                                            ? chestExercises1
                                            : chestExercises2,
                                  ),
                                  BodyPart(
                                    image: gender == 'Male'
                                        ? "assets/man/back.jpg"
                                        : "assets/woman/back.jpg",
                                    muscle: 'Back',
                                    level: '$level:',
                                    workoutList: level == 'Beginner'
                                        ? backExercises
                                        : level == 'Intermediate'
                                            ? backExercises1
                                            : backExercises2,
                                  ),
                                  BodyPart(
                                    image: gender == 'Male'
                                        ? "assets/man/arms.jpg"
                                        : "assets/woman/arms.jpg",
                                    muscle: 'Arms',
                                    level: '$level:',
                                    workoutList: level == 'Beginner'
                                        ? armExercises
                                        : level == 'Intermediate'
                                            ? armExercises1
                                            : armExercises2,
                                  ),
                                  BodyPart(
                                    image: gender == 'Male'
                                        ? "assets/man/shoulder.jpg"
                                        : "assets/woman/shoulders.jpg",
                                    muscle: 'Shoulders',
                                    level: '$level:',
                                    workoutList: shoulderExercises,
                                  ),
                                  BodyPart(
                                    image: gender == 'Male'
                                        ? "assets/man/legs.jpg"
                                        : "assets/woman/legs.jpg",
                                    muscle: 'Legs',
                                    level: '$level:',
                                    workoutList: level == 'Beginner'
                                        ? legsExercises
                                        : level == 'Intermediate'
                                            ? legsExercises1
                                            : legsExercises2,
                                  ),
                                  BodyPart(
                                    image: gender == 'Male'
                                        ? "assets/man/abs.jpg"
                                        : "assets/woman/abs.jpg",
                                    muscle: 'Abs',
                                    level: '$level:',
                                    workoutList: level == 'Beginner'
                                        ? absExercises
                                        : level == 'Intermediate'
                                            ? absExercises1
                                            : absExercises2,
                                  ),
                                  const SizedBox(height: 5),
                                  gender == 'Male'
                                      ? WorkoutLvlTilesM(
                                          ontap: () => Navigator.push(
                                                context,
                                                createRoute(
                                                  ManWorkouts(
                                                    chest: level == 'Beginner'
                                                        ? _chestBeg
                                                        : level ==
                                                                'Intermediate'
                                                            ? _chestInter
                                                            : _chestAdv,
                                                    back: level == 'Beginner'
                                                        ? _backBeg
                                                        : level ==
                                                                'Intermediate'
                                                            ? _backInter
                                                            : _backAdv,
                                                    arms: level == 'Beginner'
                                                        ? _armsBeg
                                                        : level ==
                                                                'Intermediate'
                                                            ? _armsInter
                                                            : _armsAdv,
                                                    abs: level == 'Beginner'
                                                        ? _absBeg
                                                        : level ==
                                                                'Intermediate'
                                                            ? _absInter
                                                            : _absAdv,
                                                    shoulders: level ==
                                                            'Beginner'
                                                        ? _shouldersBeg
                                                        : level ==
                                                                'Intermediate'
                                                            ? _shouldersInter
                                                            : _shouldersAdv,
                                                    legs: level == 'Beginner'
                                                        ? _legsBeg
                                                        : level ==
                                                                'Intermediate'
                                                            ? _legsInter
                                                            : _legsAdv,
                                                  ),
                                                ),
                                              ),
                                          levelname: level == 'Beginner'
                                              ? "BEGINNER: GYM"
                                              : level == 'Intermediate'
                                                  ? "INTERMEDIATE: GYM"
                                                  : "ADVANCED: GYM",
                                          level: "⭐")
                                      : WorkoutLvlTilesW(
                                          ontap: () => Navigator.push(
                                                context,
                                                createRoute(
                                                  WomanWorkouts(
                                                    chest: level == 'Beginner'
                                                        ? _chestBegWW
                                                        : level ==
                                                                'Intermediate'
                                                            ? _chestInterWW
                                                            : _chestAdvWW,
                                                    back: level == 'Beginner'
                                                        ? _backBegWW
                                                        : level ==
                                                                'Intermediate'
                                                            ? _backInterWW
                                                            : _backAdvWW,
                                                    arms: level == 'Beginner'
                                                        ? _armsBegWW
                                                        : level ==
                                                                'Intermediate'
                                                            ? _armsInterWW
                                                            : _armsAdvWW,
                                                    abs: level == 'Beginner'
                                                        ? _absBegWW
                                                        : level ==
                                                                'Intermediate'
                                                            ? _absInterWW
                                                            : _absAdvWW,
                                                    shoulders: level ==
                                                            'Beginner'
                                                        ? _shouldersBegWW
                                                        : level ==
                                                                'Intermediate'
                                                            ? _shouldersInterWW
                                                            : _shouldersAdvWW,
                                                    legs: level == 'Beginner'
                                                        ? _legsBegWW
                                                        : level ==
                                                                'Intermediate'
                                                            ? _legsInterWW
                                                            : _legsAdvWW,
                                                  ),
                                                ),
                                              ),
                                          levelname: level == 'Beginner'
                                              ? "BEGINNER: GYM"
                                              : level == 'Intermediate'
                                                  ? "INTERMEDIATE: GYM"
                                                  : "ADVANCED: GYM",
                                          level: "⭐"),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                  child: CircularProgressIndicator(
                color: primary,
              ));
            }
          }),
    );
  }

  List _chestBeg = [];
  List _backBeg = [];
  List _armsBeg = [];
  List _shouldersBeg = [];
  List _absBeg = [];
  List _legsBeg = [];

  List _chestInter = [];
  List _backInter = [];
  List _armsInter = [];
  List _shouldersInter = [];
  List _absInter = [];
  List _legsInter = [];

  List _chestAdv = [];
  List _backAdv = [];
  List _armsAdv = [];
  List _shouldersAdv = [];
  List _absAdv = [];
  List _legsAdv = [];

  List _chestBegWW = [];
  List _backBegWW = [];
  List _armsBegWW = [];
  List _shouldersBegWW = [];
  List _absBegWW = [];
  List _legsBegWW = [];

  List _chestInterWW = [];
  List _backInterWW = [];
  List _armsInterWW = [];
  List _shouldersInterWW = [];
  List _absInterWW = [];
  List _legsInterWW = [];

  List _chestAdvWW = [];
  List _backAdvWW = [];
  List _armsAdvWW = [];
  List _shouldersAdvWW = [];
  List _absAdvWW = [];
  List _legsAdvWW = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chestBeg();
    backBeg();
    armsBeg();
    absBeg();
    shouldersBeg();
    legsBeg();
    chestInter();
    backInter();
    armsInter();
    shouldersInter();
    absInter();
    legsInter();
    chestAdv();
    backAdv();
    armsAdv();
    shouldersAdv();
    absAdv();
    legsAdv();
    chestBegW();
    backBegW();
    armsBegW();
    absBegW();
    shouldersBegW();
    legsBegW();
    chestInterW();
    backInterW();
    armsInterW();
    shouldersInterW();
    absInterW();
    legsInterW();
    chestAdvW();
    backAdvW();
    armsAdvW();
    shouldersAdvW();
    absAdvW();
    legsAdvW();
  }

  Future chestBeg() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Beginner")
        .collection("Chest")
        .get();
    setState(
      () {
        _chestBeg = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future backBeg() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Beginner")
        .collection("Back")
        .get();
    setState(
      () {
        _backBeg = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future armsBeg() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Beginner")
        .collection("Arms")
        .get();
    setState(
      () {
        _armsBeg = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future shouldersBeg() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Beginner")
        .collection("Shoulders")
        .get();
    setState(
      () {
        _shouldersBeg = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future absBeg() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Beginner")
        .collection("Abs")
        .get();
    setState(
      () {
        _absBeg = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future legsBeg() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Beginner")
        .collection("Legs")
        .get();
    setState(
      () {
        _legsBeg = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future chestInter() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Intermediate")
        .collection("Chest")
        .get();
    setState(
      () {
        _chestInter = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future backInter() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Intermediate")
        .collection("Back")
        .get();
    setState(
      () {
        _backInter = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future armsInter() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Intermediate")
        .collection("Arms")
        .get();
    setState(
      () {
        _armsInter = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future shouldersInter() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Intermediate")
        .collection("Shoulders")
        .get();
    setState(
      () {
        _shouldersInter = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future absInter() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Intermediate")
        .collection("Abs")
        .get();
    setState(
      () {
        _absInter = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future legsInter() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Intermediate")
        .collection("Legs")
        .get();
    setState(
      () {
        _legsInter = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future chestAdv() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Advanced")
        .collection("Chest")
        .get();
    setState(
      () {
        _chestAdv = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future backAdv() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Advanced")
        .collection("Back")
        .get();
    setState(
      () {
        _backAdv = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future armsAdv() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Advanced")
        .collection("Arms")
        .get();
    setState(
      () {
        _armsAdv = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future shouldersAdv() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Advanced")
        .collection("Shoulders")
        .get();
    setState(
      () {
        _shouldersAdv = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future absAdv() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Advanced")
        .collection("Abs")
        .get();
    setState(
      () {
        _absAdv = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future legsAdv() async {
    var data = await FirebaseFirestore.instance
        .collection("Man")
        .doc("Advanced")
        .collection("Legs")
        .get();
    setState(
      () {
        _legsAdv = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future chestBegW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Beginner")
        .collection("Chest")
        .get();
    setState(
      () {
        _chestBegWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future backBegW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Beginner")
        .collection("Back")
        .get();
    setState(
      () {
        _backBegWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future armsBegW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Beginner")
        .collection("Arms")
        .get();
    setState(
      () {
        _armsBegWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future shouldersBegW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Beginner")
        .collection("Shoulders")
        .get();
    setState(
      () {
        _shouldersBegWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future absBegW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Beginner")
        .collection("Abs")
        .get();
    setState(
      () {
        _absBegWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future legsBegW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Beginner")
        .collection("Legs")
        .get();
    setState(
      () {
        _legsBegWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future chestInterW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Intermediate")
        .collection("Chest")
        .get();
    setState(
      () {
        _chestInterWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future backInterW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Intermediate")
        .collection("Back")
        .get();
    setState(
      () {
        _backInterWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future armsInterW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Intermediate")
        .collection("Arms")
        .get();
    setState(
      () {
        _armsInterWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future shouldersInterW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Intermediate")
        .collection("Shoulders")
        .get();
    setState(
      () {
        _shouldersInterWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future absInterW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Intermediate")
        .collection("Abs")
        .get();
    setState(
      () {
        _absInterWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future legsInterW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Intermediate")
        .collection("Legs")
        .get();
    setState(
      () {
        _legsInterWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future chestAdvW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Advanced")
        .collection("Chest")
        .get();
    setState(
      () {
        _chestAdvWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future backAdvW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Advanced")
        .collection("Back")
        .get();
    setState(
      () {
        _backAdvWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future armsAdvW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Advanced")
        .collection("Arms")
        .get();
    setState(
      () {
        _armsAdvWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future shouldersAdvW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Advanced")
        .collection("Shoulders")
        .get();
    setState(
      () {
        _shouldersAdvWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future absAdvW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Advanced")
        .collection("Abs")
        .get();
    setState(
      () {
        _absAdvWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }

  Future legsAdvW() async {
    var data = await FirebaseFirestore.instance
        .collection("Woman")
        .doc("Advanced")
        .collection("Legs")
        .get();
    setState(
      () {
        _legsAdvWW = List.from(
          data.docs.map(
            (doc) => GymWorkoutModel.fromSnapshot(doc),
          ),
        );
      },
    );
  }
}

class WorkoutCategory extends StatelessWidget {
  final String image;
  final VoidCallback ontap;
  const WorkoutCategory({
    Key? key,
    required this.image,
    required this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Ink(
        height: 260,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: bgcolor,
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF3A5160).withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            fit: BoxFit.contain,
            image: AssetImage(image),
          ),
        ),
      ),
    );
  }
}

class BodyPart extends StatelessWidget {
  final String image;
  final String muscle;
  final String level;
  final List<Exercise> workoutList;

  const BodyPart({
    Key? key,
    required this.image,
    required this.muscle,
    required this.level,
    required this.workoutList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            createRoute(
              StartWorkout(
                muscle: muscle,
                level: level,
                image: image,
                list: workoutList,
              ),
            ),
          );
        },
        child: Ink(
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                image,
              ),
            ),
            boxShadow: [shadow],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: Text(
                  '$level\n$muscle'.toUpperCase(),
                  textAlign: TextAlign.left,
                  style: h2white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
