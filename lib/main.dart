import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:travel_cost_planner_europe/app.dart';
import 'package:travel_cost_planner_europe/core/constants/ad_constants.dart';
import 'package:travel_cost_planner_europe/core/utils/ad_audit_log.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/domain/services/ad_service.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = await HiveService.init();

  AdService? adService;
  if (AdService.isMobileAdsSupported) {
    adAuditLog(
      'Starting MobileAds init kReleaseMode=$kReleaseMode '
      'useTestAdUnits=${AdConstants.useTestAdUnits} '
      'bannerUnit=${AdConstants.bannerAdUnitId} '
      'interstitialUnit=${AdConstants.interstitialAdUnitId}',
    );
    try {
      final initStatus = await MobileAds.instance.initialize();
      for (final entry in initStatus.adapterStatuses.entries) {
        final adapter = entry.value;
        adAuditLog(
          'MobileAds initialize adapter=${entry.key} '
          'state=${adapter.state} latencyMs=${adapter.latency} '
          'description=${adapter.description}',
        );
      }
      adAuditLog('MobileAds initialize completed');
      adService = AdService();
      await adService.initialize();
    } catch (error, stackTrace) {
      adAuditLog('MobileAds initialize failed: $error');
      adAuditLog('MobileAds initialize stack: $stackTrace');
      adService = null;
    }
  } else {
    adAuditLog('MobileAds skipped: platform not supported');
  }

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        if (adService != null) adServiceProvider.overrideWithValue(adService),
      ],
      child: const TravelCostPlannerApp(),
    ),
  );
}
