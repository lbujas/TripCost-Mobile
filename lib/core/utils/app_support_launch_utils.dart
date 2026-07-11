import 'package:url_launcher/url_launcher.dart';

/// Opens Google Play and contact links for app support actions.
class AppSupportLaunchUtils {
  AppSupportLaunchUtils._();

  static const String playStorePackageId = 'pl.tripcost.app';
  static const String contactEmail = 'tripcost@codeluk.dev';

  static Uri googlePlayMarketUri(String packageId) {
    return Uri.parse('market://details?id=$packageId');
  }

  static Uri googlePlayWebUri(String packageId) {
    return Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageId',
    );
  }

  static Uri contactEmailUri({
    required String email,
    required String subject,
  }) {
    return Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: <String, String>{'subject': subject},
    );
  }

  static Future<bool> launchGooglePlayListing({
    String packageId = playStorePackageId,
  }) async {
    final marketLaunched = await launchUrl(
      googlePlayMarketUri(packageId),
      mode: LaunchMode.externalApplication,
    );
    if (marketLaunched) {
      return true;
    }

    return launchUrl(
      googlePlayWebUri(packageId),
      mode: LaunchMode.externalApplication,
    );
  }

  static Future<bool> launchContactEmail({
    required String subject,
    String email = contactEmail,
  }) {
    return launchUrl(
      contactEmailUri(email: email, subject: subject),
      mode: LaunchMode.externalApplication,
    );
  }
}
