import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OriginLocalizationService {
  OriginLocalizationService._();

  static String getOriginCityName(
    String originCityId,
    BuildContext context, {
    String? fallbackName,
  }) {
    final l10n = AppLocalizations.of(context);
    final localized = switch (originCityId) {
      'krakow' => l10n.origin_city_krakow,
      'katowice' => l10n.origin_city_katowice,
      'wroclaw' => l10n.origin_city_wroclaw,
      'warsaw' => l10n.origin_city_warsaw,
      'poznan' => l10n.origin_city_poznan,
      'gdansk' => l10n.origin_city_gdansk,
      'szczecin' => l10n.origin_city_szczecin,
      'lodz' => l10n.origin_city_lodz,
      'rzeszow' => l10n.origin_city_rzeszow,
      'lublin' => l10n.origin_city_lublin,
      'bialystok' => l10n.origin_city_bialystok,
      _ => originCityId,
    };

    if (localized != originCityId) {
      return localized;
    }

    return fallbackName ?? originCityId;
  }
}
