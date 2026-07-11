import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/core/utils/app_support_launch_utils.dart';

void main() {
  group('AppSupportLaunchUtils', () {
    test('googlePlayMarketUri uses market scheme', () {
      final uri = AppSupportLaunchUtils.googlePlayMarketUri('pl.tripcost.app');

      expect(uri.scheme, 'market');
      expect(uri.toString(), 'market://details?id=pl.tripcost.app');
    });

    test('googlePlayWebUri uses Play Store https fallback', () {
      final uri = AppSupportLaunchUtils.googlePlayWebUri('pl.tripcost.app');

      expect(uri.scheme, 'https');
      expect(
        uri.toString(),
        'https://play.google.com/store/apps/details?id=pl.tripcost.app',
      );
    });

    test('contactEmailUri builds mailto with subject', () {
      final uri = AppSupportLaunchUtils.contactEmailUri(
        email: 'tripcost@codeluk.dev',
        subject: 'TripCost - Contact',
      );

      expect(uri.scheme, 'mailto');
      expect(uri.path, 'tripcost@codeluk.dev');
      expect(uri.queryParameters['subject'], 'TripCost - Contact');
    });
  });
}
