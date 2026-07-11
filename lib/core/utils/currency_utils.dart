import 'package:flutter/material.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static const supportedCurrencies = {'EUR', 'PLN', 'CZK', 'HUF'};

  static String currencyForLanguage(String languageCode) {
    return switch (languageCode) {
      'pl' => 'PLN',
      'cs' => 'CZK',
      'hu' => 'HUF',
      'sk' => 'EUR',
      'de' => 'EUR',
      'hr' => 'EUR',
      'en' => 'EUR',
      _ => 'EUR',
    };
  }

  static String currencyForDeviceLocale(Locale locale) {
    final countryCode = locale.countryCode?.toUpperCase();
    if (countryCode != null && countryCode.isNotEmpty) {
      return switch (countryCode) {
        'PL' => 'PLN',
        'CZ' => 'CZK',
        'HU' => 'HUF',
        _ => currencyForLanguage(locale.languageCode),
      };
    }

    return currencyForLanguage(locale.languageCode);
  }

  static String resolveDisplayCurrency({
    required AppSettings settings,
    required Locale deviceLocale,
  }) {
    if (settings.preferredCurrency != 'auto') {
      return settings.preferredCurrency;
    }

    return currencyForDeviceLocale(deviceLocale);
  }
}
