import 'package:flutter/material.dart';
import 'package:travel_cost_planner_europe/domain/services/ad_service.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';

/// Layout helpers for screens that pin a standard AdMob banner at the bottom.
class AdBannerLayout {
  AdBannerLayout._();

  /// Standard [AdSize.banner] height in logical pixels.
  static const double standardBannerHeight = 50;

  static const double bannerSpacing = AppSpacing.sm;

  static bool get shouldReserveBannerSpace => AdService.isMobileAdsSupported;

  /// System bottom inset (gesture bar / navigation bar).
  static double systemBottomInset(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom;
  }

  /// Banner slot height plus spacing above the system inset.
  static double bannerSlotHeight(BuildContext context) {
    if (!shouldReserveBannerSpace) {
      return 0;
    }
    return standardBannerHeight + bannerSpacing;
  }

  /// Total vertical space taken by banner slot and system bottom inset.
  static double totalBottomReservation(BuildContext context) {
    return systemBottomInset(context) + bannerSlotHeight(context);
  }

  /// Bottom padding for scrollable content that sits above a footer row.
  static double scrollBottomPadding(
    BuildContext context, {
    double footerHeight = 0,
  }) {
    return AppSpacing.lg + footerHeight;
  }
}
