import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../utilities/constants.dart';
import '../../utilities/monetization/adservice.dart';

errorMsg(String text, BuildContext context) {
  ElegantNotification.error(
          animation: AnimationType.fromBottom,
          
          title: const Text("Error",
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          description: Text(text.split("] ").last,
              style: const TextStyle(color: color, fontSize: 12)))
      .show(context);
}

successMsg(String text, BuildContext context) {
  ElegantNotification.success(
          animation: AnimationType.fromBottom,
          
          title: const Text("Success",
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          description:
              Text(text, style: const TextStyle(color: color, fontSize: 12)))
      .show(context);
}

final BannerAd onExitAdUnit = BannerAd(
  adUnitId: AdService.adUnitId,
  size: AdSize.mediumRectangle,
  request: const AdRequest(),
  listener: AdService.bannerAdListener,
)..load();

exitDialogue(void Function() onCancelPress, BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.bottomSlide,
    dismissOnBackKeyPress: true,
    body: Column(
      children: [
        const Text(
          'Do You Really Want To Exit?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: AdWidget(ad: onExitAdUnit),
        ),
      ],
    ),
    btnCancelOnPress: onCancelPress,
    btnOkOnPress: () => SystemNavigator.pop(),
  ).show();
}
