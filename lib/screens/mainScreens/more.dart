import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:specifit/screens/mainScreens/gyms.dart';
import 'package:specifit/utilities/export.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  State<More> createState() => _MoreState();
}

class _MoreState extends State<More> {
  final BannerAd bannerAdUnit1 = BannerAd(
    adUnitId: AdService.adUnitId,
    size: AdSize.mediumRectangle,
    request: const AdRequest(),
    listener: AdService.bannerAdListener,
  )..load();
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
    return WillPopScope(
      onWillPop: () => exitDialogue(() => _interstitialAd!.show(), context),
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text("More")),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Gyms'),
              onTap: () {
                Navigator.push(context, createRoute(const Gyms()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback_rounded),
              title: const Text('Feedback'),
              onTap: () async {
                final Uri params = Uri(
                  scheme: 'mailto',
                  path: 'isedenlive@gmail.com',
                  query:
                      'subject=App Feedback&body=Hey there, I have some feedback for SpeciFit App.\nHere are the details:\n',
                );
                await launchUrl(params);
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Privacy Policy'),
              onTap: () {
                launchUrlString(
                    "https://docs.google.com/document/d/11yhqBvcsCultC2CnwsjpIboPXyrN0z0vlSr9PZF658Y/edit?usp=sharing");
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Licenses'),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'SpeciFit',
                  applicationVersion: 'Version: 1.2.6',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'SpeciFit',
                  applicationVersion: 'Version: 1.2.6',
                  applicationIcon: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: primary,
                    ),
                    child: Image.asset(
                      height: 64,
                      'assets/images/icon.png',
                    ),
                  ),
                  children: const [
                    SizedBox(height: 16),
                    Text(
                      'Specifit is a fitness app designed to help you achieve your fitness goals. Whether you want to lose weight, build muscle, or improve your overall health and fitness, Specifit has everything you need to succeed.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'With Specifit, you can:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '- Track daily workout routines',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '- Set goals and track your progress',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '- Access a library of 1300+ exercises with animations',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '- Keep track of your daily calorie & macro intake',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Thank you for choosing SpeciFit for your fitness journey!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: AdWidget(ad: bannerAdUnit1))
          ],
        ),
      ),
    );
  }
}
