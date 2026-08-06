import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  RevenueCatService._();

  static Future<void> initialize({
    required String androidApiKey,
    required String iosApiKey,
  }) async {

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(androidApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(iosApiKey);
    } else {
      return;
    }

    await Purchases.configure(configuration);

    debugPrint("RevenueCat initialized");
  }

  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint("RevenueCat getOfferings error: $e");
      return null;
    }
  }

  static Future<PurchaseResult?> purchase(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      return purchaseResult;
    } on PurchasesError catch (e) {
      debugPrint("Purchase failed: ${e.message}");
      return null;
    }
  }

  static Future<CustomerInfo?> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      debugPrint("Restore failed: $e");
      return null;
    }
  }

  static Future<bool> isPremiumUser() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint("CustomerInfo error: $e");
      return false;
    }
  }

}