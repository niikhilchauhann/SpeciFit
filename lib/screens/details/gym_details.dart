import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:specifit/screens/details/small_widget.dart';
import '../../utilities/export.dart';

class GymDetails extends StatefulWidget {
  final String address;
  final String facilities;
  final dynamic fees;
  final String image;
  final String orientation;
  final dynamic size;
  final String name;
  final String trainer;
  final dynamic contact;
  final dynamic rating;
  final List images;

  const GymDetails({
    super.key,
    required this.address,
    required this.facilities,
    required this.fees,
    required this.image,
    required this.orientation,
    required this.size,
    required this.name,
    required this.trainer,
    required this.images,
    required this.contact,
    required this.rating,
  });

  @override
  State<GymDetails> createState() => _GymDetailsState();
}

class _GymDetailsState extends State<GymDetails> with TickerProviderStateMixin {
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
  }

  var themedColor = const Color(0xff7b4425);
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: bgcolor,
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
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 35),
                          Text("Orientation: ${widget.orientation}",
                              textAlign: TextAlign.left,
                              style: theme.titleLarge),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.name,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    letterSpacing: 0.27,
                                    color: themedColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                              Text(
                                "⭐ ${widget.rating}.0",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.27,
                                  color: themedColor,
                                ),
                                overflow: TextOverflow.fade,
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
                                    txt1: widget.trainer,
                                    txt2: 'Trainer',
                                    txtcolor: themedColor),
                                SmallWidget(
                                    txt1: "${widget.size.toString()} m²",
                                    txt2: 'Size',
                                    txtcolor: themedColor),
                                SmallWidget(
                                    txt1: "₹${widget.fees.toString()}",
                                    txt2: 'Fees',
                                    txtcolor: themedColor)
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: opacity2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Facilities: ${widget.facilities}",
                                  style: theme.bodyMedium,
                                  overflow: TextOverflow.fade,
                                ),
                                Text(
                                  "Address: ${widget.address}",
                                  style: theme.bodyMedium,
                                  overflow: TextOverflow.fade,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // CarouselSlider.builder(
                    //   itemCount: widget.images.length,
                    //   itemBuilder: (context, index, realIndex) {
                    //     return Container(
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(20),
                    //         image: DecorationImage(
                    //           fit: BoxFit.cover,
                    //           image: CachedNetworkImageProvider(
                    //               widget.images[index]),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   options: CarouselOptions(
                    //     height: 185,
                    //     viewportFraction: 0.84,
                    //     enlargeCenterPage: true,
                    //   ),
                    // ),
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
                        color: themedColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        _rewardedInterstitialAd!.show(
                          onUserEarnedReward:
                              (AdWithoutView ad, RewardItem reward) {},
                        );
                        AwesomeDialog(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                context: context,
                                dialogType: DialogType.info,
                                animType: AnimType.rightSlide,
                                dismissOnBackKeyPress: true,
                                title: 'How To Reach?',
                                body: Text(
                                  "Contact: ${widget.contact}\nAddress: ${widget.address}",
                                  style: theme.bodyMedium,
                                ),
                                btnOkText: "OKAY",
                                btnOkOnPress: () {})
                            .show();
                      },
                      child: Container(
                        height: 48,
                        width: MediaQuery.of(context).size.width - 112,
                        decoration: BoxDecoration(
                          color: themedColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: themedColor.withOpacity(0.5),
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'How To Reach?',
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
                color: themedColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0)),
                elevation: 10.0,
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Icon(
                      Icons.location_on,
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

  Widget getSmallWidget(String text1, String txt2) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF3A5160).withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: themedColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                txt2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: Color(0xFF3A5160),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
