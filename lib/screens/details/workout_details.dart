import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../utilities/export.dart';
import 'small_widget.dart';

class WorkoutDetails extends StatefulWidget {
  final String category;
  final String howTo;
  final String howToVideo;
  final String image;
  final String kcal;
  final String name;
  final String target;
  const WorkoutDetails({
    super.key,
    required this.category,
    required this.howTo,
    required this.howToVideo,
    required this.image,
    required this.kcal,
    required this.name,
    required this.target,
  });

  @override
  State<WorkoutDetails> createState() => _WorkoutDetailsState();
}

class _WorkoutDetailsState extends State<WorkoutDetails>
    with TickerProviderStateMixin {
  final double infoHeight = 364;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  @override
  void initState() {
    createInterstitialAd();
    createRewardedInterstitialAd();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: const Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    setData();
    super.initState();
  }

  Future<void> setData() async {
    animationController?.forward();
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity1 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity2 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity3 = 1.0;
    });
  }

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

  RewardedInterstitialAd? _rewardedInterstitialAd;
  createRewardedInterstitialAd() {
    RewardedInterstitialAd.loadWithAdManagerAdRequest(
      adUnitId: AdService.adUnitIdRewardedInter,
      adManagerRequest: const AdManagerAdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          _rewardedInterstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {},
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
    _rewardedInterstitialAd?.dispose();
  }

  IconData onTapIcon = Icons.check_box_outline_blank_rounded;
  bool hasImage = true;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    if (widget.howToVideo == '') {
      setState(() {
        hasImage = false;
      });
    } else {
      setState(() {
        hasImage = true;
      });
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 2.6,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    widget.image,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: (MediaQuery.of(context).size.width / 1.2) - 24.0,
            child: Container(
              height: MediaQuery.of(context).size.height / 1.5,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [shadow],
                color: Theme.of(context).cardColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  children: [
                    const SizedBox(height: 35),
                    Text("Target: ${widget.target}",
                        textAlign: TextAlign.left, style: theme.titleLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: Text(
                            widget.name,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              letterSpacing: 0.27,
                              color: primary,
                            ),
                            overflow: TextOverflow.fade,
                            softWrap: true,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _interstitialAd!.show();
                            setState(() {
                              onTapIcon = Icons.check_box;
                            });
                          },
                          child: Icon(
                            onTapIcon,
                            size: 24,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: opacity1,
                      child: Row(
                        children: [
                          SmallWidget(
                              txt1: widget.kcal,
                              txt2: 'Calories',
                              txtcolor: primary),
                          SmallWidget(
                              txt1: "8-15", txt2: 'Reps', txtcolor: primary),
                          SmallWidget(
                              txt1: "3-4", txt2: 'Sets', txtcolor: primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: opacity2,
                      child: Text(
                        widget.howTo,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: opacity3,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 16, right: 24),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                        border: Border.all(
                            color: const Color(0xFF3A5160).withOpacity(0.2)),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        AwesomeDialog(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                context: context,
                                dialogType: DialogType.info,
                                animType: AnimType.rightSlide,
                                dismissOnBackKeyPress: true,
                                body: Column(
                                  children: [
                                    Text(
                                      "How to perform?",
                                      style: theme.titleMedium,
                                    ),
                                    const SizedBox(height: 10),
                                    hasImage
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: CachedNetworkImage(
                                              imageUrl: widget.howToVideo,
                                            ),
                                          )
                                        : SizedBox(
                                            child: Text(
                                              "Sorry, no data available",
                                              style: theme.titleMedium,
                                            ),
                                          )
                                  ],
                                ),
                                btnOkText: "OKAY",
                                btnOkOnPress: () {
                                  _rewardedInterstitialAd!.show(
                                    onUserEarnedReward: (AdWithoutView ad,
                                        RewardItem reward) {},
                                  );
                                },
                                descTextStyle: hNormal)
                            .show();
                      },
                      child: Container(
                        height: 48,
                        width: MediaQuery.of(context).size.width - 112,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: primary.withOpacity(0.5),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'How To Perform?',
                            textAlign: TextAlign.left,
                            style: h2white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: (MediaQuery.of(context).size.width / 1.2) - 24.0 - 35,
            right: 35,
            child: ScaleTransition(
              alignment: Alignment.center,
              scale: CurvedAnimation(
                  parent: animationController!, curve: Curves.fastOutSlowIn),
              child: Card(
                color: primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0)),
                elevation: 10.0,
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Icon(
                      Icons.fitness_center,
                      color: Color(0xFFFFFFFF),
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
