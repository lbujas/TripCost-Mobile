import 'package:flutter/foundation.dart';

/// Google AdMob ad unit and app IDs (test IDs until production IDs are configured).
class AdConstants {
  AdConstants._();

  // Google official test ad unit IDs.
  static const String androidBannerTestId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String androidInterstitialTestId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String iosBannerTestId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String iosInterstitialTestId =
      'ca-app-pub-3940256099942544/4411468910';

// Production ad unit IDs.
  static const String androidBannerProductionId =
      'ca-app-pub-7995095759966826/4733760969';
  static const String androidInterstitialProductionId =
      'ca-app-pub-7995095759966826/5252600323';

  static const String iosBannerProductionId = 'TODO_IOS_BANNER';
  static const String iosInterstitialProductionId = 'TODO_IOS_INTERSTITIAL';

  static const String androidAppIdTest =
      'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppIdTest =
      'ca-app-pub-3940256099942544~1458002511';
  /// Use test units in debug and in release while production placeholders remain.
  static bool get useTestAdUnits {
    if (kDebugMode) {
      return true;
    }
    return androidBannerProductionId.startsWith('TODO_') ||
        androidInterstitialProductionId.startsWith('TODO_');
  }

  static String get bannerAdUnitId {
    if (useTestAdUnits) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? iosBannerTestId
          : androidBannerTestId;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? iosBannerProductionId
        : androidBannerProductionId;
  }

  static String get interstitialAdUnitId {
    if (useTestAdUnits) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? iosInterstitialTestId
          : androidInterstitialTestId;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? iosInterstitialProductionId
        : androidInterstitialProductionId;
  }
}
