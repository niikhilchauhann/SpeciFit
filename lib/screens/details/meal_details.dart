import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../utilities/export.dart';
import 'small_widget.dart';

class MealDetails extends StatefulWidget {
  final String description;
  final String keywords;
  final String name;
  final String slug;
  final String videoUrl;
  final String thumbnailUrl;
  final String cookTime;
  final String prepTime;
  final String totalTime;
  final String score;
  final String protein;
  final String fat;
  final String calories;
  final String sugar;
  final String carbohydrates;
  final String fiber;

  const MealDetails({
    super.key,
    required this.description,
    required this.keywords,
    required this.name,
    required this.slug,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.cookTime,
    required this.prepTime,
    required this.totalTime,
    required this.score,
    required this.protein,
    required this.fat,
    required this.calories,
    required this.sugar,
    required this.carbohydrates,
    required this.fiber,
  });

  @override
  State<MealDetails> createState() => _MealDetailsState();
}

class _MealDetailsState extends State<MealDetails>
    with TickerProviderStateMixin {
  final double infoHeight = 364;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  late BetterPlayerController _betterPlayerController;
  double _aspectRatio = 1 / 1;
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
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 1,
        autoPlay: false,
        showPlaceholderUntilPlay: true,
        placeholderOnTop: true,
        placeholder: Image.network(widget.thumbnailUrl),
        looping: false,
        fit: BoxFit.contain,
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoUrl,
      ),
    );
    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        setState(() {
          _aspectRatio =
              _betterPlayerController.videoPlayerController!.value.aspectRatio;
        });
      }
    });
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
  RewardedInterstitialAd? _rewardedInterstitialAd;

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
    _betterPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    String dummyDescription =
        "Looking for a quick and easy recipe? Give our ${widget.name} a try - it only takes ${widget.totalTime} mins to make! Plus, it's packed with ${widget.protein}g protein, ${widget.fat}g fat, and just ${widget.sugar}g sugar per serving, making it a healthy choice. And with an impressive ${widget.score} rating, your guests are sure to be impressed. Don't wait to try this delicious dish!";
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
              height: MediaQuery.of(context).size.width - 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    widget.thumbnailUrl,
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
                    Text("Cook Time: ${widget.cookTime} min",
                        textAlign: TextAlign.left, style: theme.titleLarge),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: Text(
                            widget.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              letterSpacing: 0.27,
                              color: Color(0xff147e4e),
                            ),
                            overflow: TextOverflow.fade,
                            softWrap: true,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              size: 24,
                              color: Color(0xff147e4e),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.score,
                              style: const TextStyle(
                                color: Color(0xff147e4e),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: opacity1,
                      child: Row(
                        children: [
                          SmallWidget(
                              txt1: "${widget.carbohydrates}g", txt2: 'Carbs'),
                          SmallWidget(
                              txt1: "${widget.protein}g", txt2: 'Protein'),
                          SmallWidget(txt1: "${widget.fat}g", txt2: 'Fats'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: opacity2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.description == ''
                                ? dummyDescription
                                : widget.description,
                            style: theme.bodyMedium,
                            overflow: TextOverflow.fade,
                          ),
                          const SizedBox(height: 20),
                          NutrientWidget(
                              name: "Calories",
                              value: "${widget.calories} kcal"),
                          NutrientWidget(
                              name: "Sugar", value: "${widget.sugar} g"),
                          NutrientWidget(
                              name: "Fiber", value: "${widget.fiber} g"),
                          const SizedBox(height: 15),
                          const Divider(thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TimeWidget(
                                title: 'Prep',
                                subtitle: widget.prepTime,
                              ),
                              TimeWidget(
                                title: 'Cook',
                                subtitle: widget.cookTime,
                              ),
                              TimeWidget(
                                title: 'Total',
                                subtitle: widget.totalTime,
                              ),
                            ],
                          ),
                          const Divider(thickness: 1),
                          const SizedBox(height: 15),
                          Text("How To Cook:",
                              textAlign: TextAlign.left,
                              style: theme.titleMedium),
                          const SizedBox(height: 15),
                          AspectRatio(
                            aspectRatio: _aspectRatio,
                            child: BetterPlayer(
                                controller: _betterPlayerController),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Recipe from tasty.co",
                            style: theme.labelLarge,
                          ),
                        ],
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
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xff147e4e),
                        size: 28,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        _interstitialAd!.show();
                        launchUrlString(
                            "https://tasty.co/recipe/${widget.slug}",
                            mode: LaunchMode.inAppWebView);
                      },
                      child: Container(
                        height: 48,
                        width: MediaQuery.of(context).size.width - 112,
                        decoration: BoxDecoration(
                          color: const Color(0xff147e4e),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xff147e4e).withOpacity(0.5),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'How To Cook?',
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
                color: const Color(0xff147e4e),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0)),
                elevation: 10.0,
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Icon(
                      Icons.restaurant_menu,
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

class TimeWidget extends StatelessWidget {
  const TimeWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$title Time',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          '$subtitle min',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}
