import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Localizes country codes and route place names for display.
class CountryLocalizationService {
  CountryLocalizationService._();

  static String getCountryName(String countryCode, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (countryCode.toUpperCase()) {
      'PL' => l10n.country_pl,
      'HR' => l10n.country_hr,
      'SK' => l10n.country_sk,
      'HU' => l10n.country_hu,
      'AT' => l10n.country_at,
      'SI' => l10n.country_si,
      'CZ' => l10n.country_cz,
      'DE' => l10n.country_de,
      _ => countryCode,
    };
  }

  static String getPlaceName(String place, BuildContext context) {
    final code = _englishNameToCode(place);
    if (code != null) {
      return getCountryName(code, context);
    }

    if (place.length == 2) {
      return getCountryName(place, context);
    }

    return place;
  }

  static String getCountryWithFlag(String countryCode, BuildContext context) {
    return '${_flagEmoji(countryCode)} ${getCountryName(countryCode, context)}';
  }

  static String formatDirectionFlags(String originCode, String destinationCode) {
    return '${_flagEmoji(originCode)} → ${_flagEmoji(destinationCode)}';
  }

  static String formatRouteChain(
    List<String> countryCodes,
    BuildContext context, {
    bool compact = false,
  }) {
    final parts =
        countryCodes.map((code) => getCountryWithFlag(code, context));
    return parts.join(' → ');
  }

  static String formatRouteEndpoints(
    String origin,
    String destination,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context);
    return l10n.routeFromTo(
      getPlaceName(origin, context),
      getPlaceName(destination, context),
    );
  }

  static String? _englishNameToCode(String place) {
    return switch (place) {
      'Poland' => 'PL',
      'Croatia' => 'HR',
      'Slovakia' => 'SK',
      'Hungary' => 'HU',
      'Austria' => 'AT',
      'Slovenia' => 'SI',
      'Czech Republic' => 'CZ',
      'Germany' => 'DE',
      _ => null,
    };
  }

  static String _flagEmoji(String countryCode) {
    return countryCode.toUpperCase().runes
        .map((rune) => String.fromCharCode(rune + 127397))
        .join();
  }
}
