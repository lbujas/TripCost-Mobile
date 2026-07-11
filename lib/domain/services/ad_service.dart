import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:travel_cost_planner_europe/core/constants/ad_constants.dart';
import 'package:travel_cost_planner_europe/core/utils/ad_audit_log.dart';
import 'package:travel_cost_planner_europe/domain/models/ad_settings.dart';
/// Manages banner and interstitial ads for the travel cost planner MVP.
class AdService {
  AdService({AdSettings settings = const AdSettings()}) : _settings = settings;

  final AdSettings _settings;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _interstitialLoading = false;
  bool _initialized = false;
  int _sessionCalculationCount = 0;

  static bool get isMobileAdsSupported {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  int get sessionCalculationCount => _sessionCalculationCount;

  bool get isInterstitialLoaded => _interstitialAd != null;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    if (!isMobileAdsSupported) {
      adAuditLog('Mobile ads not supported on this platform.');
      return;
    }

    adAuditLog('AdService initialize (interstitialEnabled=${_settings.interstitialEnabled})');
    await loadInterstitialAd();
  }

  Future<BannerAd?> loadBannerAd() async {
    if (!isMobileAdsSupported) {
      adAuditLog('BannerAd skipped: platform not supported');
      return null;
    }

    disposeBannerAd();

    final adUnitId = AdConstants.bannerAdUnitId;
    adAuditLog('BannerAd load start unitId=$adUnitId useTestAdUnits=${AdConstants.useTestAdUnits}');

    try {
      final completer = Completer<BannerAd?>();
      final banner = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _bannerAd = ad as BannerAd;
            adAuditLog(
              'BannerAd loaded unitId=$adUnitId '
              'size=${_bannerAd!.size.width}x${_bannerAd!.size.height}',
            );
            if (!completer.isCompleted) {
              completer.complete(_bannerAd);
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _bannerAd = null;
            adAuditLog(
              'BannerAd failed unitId=$adUnitId '
              'code=${error.code} domain=${error.domain} message=${error.message}',
            );
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
        ),
      );

      await banner.load();
      return completer.future;
    } catch (error, stackTrace) {
      adAuditLog('BannerAd load exception unitId=$adUnitId error=$error');
      adAuditLog('BannerAd load stack: $stackTrace');
      return null;
    }
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  Future<void> loadInterstitialAd() async {
    if (!isMobileAdsSupported || _interstitialLoading || _interstitialAd != null) {
      return;
    }

    _interstitialLoading = true;
    final adUnitId = AdConstants.interstitialAdUnitId;
    adAuditLog(
      'Interstitial load start unitId=$adUnitId useTestAdUnits=${AdConstants.useTestAdUnits}',
    );

    try {
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialLoading = false;
            adAuditLog('Interstitial loaded unitId=$adUnitId');
          },
          onAdFailedToLoad: (error) {
            _interstitialAd = null;
            _interstitialLoading = false;
            adAuditLog(
              'Interstitial failed unitId=$adUnitId '
              'code=${error.code} domain=${error.domain} message=${error.message}',
            );
          },
        ),
      );
    } catch (error, stackTrace) {
      _interstitialLoading = false;
      adAuditLog('Interstitial load exception unitId=$adUnitId error=$error');
      adAuditLog('Interstitial load stack: $stackTrace');
    }
  }

  /// Shows an interstitial after every 3rd successful calculation in this session.
  Future<void> showInterstitialIfNeeded(int calculationsCount) async {
    _sessionCalculationCount++;

    final sessionCount = _sessionCalculationCount;
    final shouldShow = sessionCount > 0 && sessionCount % 3 == 0;
    final loaded = _interstitialAd != null;

    adAuditLog(
      'Interstitial show check session=$sessionCount persisted=$calculationsCount '
      'loaded=$loaded shouldShow=$shouldShow enabled=${_settings.interstitialEnabled}',
    );

    if (!_settings.interstitialEnabled) {
      adAuditLog('Interstitial show attempt skipped: disabled');
      return;
    }

    if (!shouldShow) {
      adAuditLog('Interstitial show attempt skipped: not every 3rd result');
      return;
    }

    final interstitial = _interstitialAd;
    if (interstitial == null) {
      adAuditLog('Interstitial show attempt skipped: not loaded');
      unawaited(loadInterstitialAd());
      return;
    }

    _interstitialAd = null;
    adAuditLog('Interstitial show attempt starting');

    final completer = Completer<void>();

    interstitial.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        adAuditLog('Interstitial dismissed');
        unawaited(loadInterstitialAd());
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        adAuditLog(
          'Interstitial show failed code=${error.code} domain=${error.domain} '
          'message=${error.message}',
        );
        unawaited(loadInterstitialAd());
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onAdShowedFullScreenContent: (_) {
        adAuditLog('Interstitial show succeeded');
      },
    );

    try {
      await interstitial.show();
      await completer.future;
    } catch (error, stackTrace) {
      interstitial.dispose();
      adAuditLog('Interstitial show exception error=$error');
      adAuditLog('Interstitial show stack: $stackTrace');
      unawaited(loadInterstitialAd());
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  void dispose() {
    disposeBannerAd();
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
