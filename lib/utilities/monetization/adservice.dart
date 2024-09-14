import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String adUnitId = 'ca-app-pub-9692880804845863/5829795260';
  static String adUnitIdInterstitial = 'ca-app-pub-9692880804845863/7882103339';
  static String adUnitIdRewarded = 'ca-app-pub-9692880804845863/8612110233';
  static String adUnitIdRewardedInter =
      'ca-app-pub-9692880804845863/6569021665';
  static final BannerAdListener bannerAdListener = BannerAdListener(
      onAdLoaded: (Ad ad) {},
      onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose());
}
