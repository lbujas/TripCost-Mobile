import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:travel_cost_planner_europe/core/utils/ad_audit_log.dart';
import 'package:travel_cost_planner_europe/domain/services/ad_service.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/ad_banner_layout.dart';

/// Full-width banner ad pinned to the bottom of a screen via [Scaffold.bottomNavigationBar].
class AdBannerWidget extends ConsumerStatefulWidget {
  const AdBannerWidget({super.key});

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _collapsed = false;
  AdService? _adService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _adService = ref.read(adServiceProvider);
      _loadBanner();
    });
  }

  Future<void> _loadBanner() async {
    final adService = _adService;
    if (adService == null) {
      adAuditLog('AdBannerWidget skipped: adService is null');
      return;
    }

    final banner = await adService.loadBannerAd();

    if (!mounted) {
      return;
    }

    adAuditLog(
      banner == null
          ? 'AdBannerWidget load finished: no banner'
          : 'AdBannerWidget load finished: banner ready',
    );

    setState(() {
      _bannerAd = banner;
      _collapsed = banner == null;
    });
  }

  @override
  void dispose() {
    _adService?.disposeBannerAd();
    super.dispose();
  }

  double get _reservedHeight {
    if (_bannerAd != null) {
      return _bannerAd!.size.height.toDouble();
    }
    return AdBannerLayout.standardBannerHeight;
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.isMobileAdsSupported) {
      return const SizedBox.shrink();
    }

    final showAd = !_collapsed && _bannerAd != null;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      minimum: EdgeInsets.zero,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AdBannerLayout.bannerSpacing),
            SizedBox(
              width: double.infinity,
              height: _reservedHeight,
              child: showAd
                  ? AdWidget(ad: _bannerAd!)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
