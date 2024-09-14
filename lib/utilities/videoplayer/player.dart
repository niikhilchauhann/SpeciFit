import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:specifit/utilities/export.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'meta_data_section.dart';

class VideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double startAt;
  const VideoPlayer({super.key, required this.videoUrl, this.startAt = 0.0});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  // RewardedAd? _rewardedAd;
  // createRewardedAd() {
  //   RewardedAd.load(
  //       adUnitId: AdService.adUnitIdRewarded,
  //       request: const AdRequest(),
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //           onAdLoaded: (RewardedAd ad) {
  //             _rewardedAd = ad;
  //           },
  //           onAdFailedToLoad: (LoadAdError error) {}));
  // }

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

  final BannerAd bannerAdUnit = BannerAd(
    adUnitId: AdService.adUnitId,
    size: AdSize.mediumRectangle,
    request: const AdRequest(),
    listener: AdService.bannerAdListener,
  )..load();

  late YoutubePlayerController _controller;

  @override
  void initState() {
    createInterstitialAd();
    // createRewardedAd();
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        enableCaption: false,
        mute: false,
        showFullscreenButton: true,
        strictRelatedVideos: true,
        loop: false,
      ),
    );
    _controller.listen((event) {
      if (_controller.value.playerState == PlayerState.ended) {
        _interstitialAd!.show();
      }
    });
    _controller.setFullScreenListener(
      (isFullScreen) {
        log('${isFullScreen ? 'Entered' : 'Exited'} Fullscreen.');
      },
    );

    _controller.loadVideoById(
        videoId: widget.videoUrl, startSeconds: widget.startAt);
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    // _rewardedAd!.dispose();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Workout Video',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            centerTitle: true,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (kIsWeb && constraints.maxWidth > 750) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          player,
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Controls(),
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                children: [
                  player,
                  const VideoPositionIndicator(),
                  const Controls(),
                  SizedBox(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: AdWidget(ad: bannerAdUnit)),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class Controls extends StatelessWidget {
  const Controls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MetaDataSection(),
          _space,
        ],
      ),
    );
  }

  Widget get _space => const SizedBox(height: 10);
}

class VideoPositionIndicator extends StatelessWidget {
  const VideoPositionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.ytController;

    return StreamBuilder<YoutubeVideoState>(
      stream: controller.videoStateStream,
      initialData: const YoutubeVideoState(),
      builder: (context, snapshot) {
        final position = snapshot.data?.position.inMilliseconds ?? 0;
        final duration = controller.metadata.duration.inMilliseconds;

        return LinearProgressIndicator(
          value: duration == 0 ? 0 : position / duration,
          minHeight: 1,
        );
      },
    );
  }
}
