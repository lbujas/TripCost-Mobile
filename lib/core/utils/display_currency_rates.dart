import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/core/utils/formatters.dart';
import 'package:travel_cost_planner_europe/core/utils/money_formatter.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';

/// Resolves exchange rates and formats stored PLN amounts for display.
class DisplayCurrencyRates {
  DisplayCurrencyRates._();

  static CurrencyRates settingsFallback(AppSettings settings) {
    return CurrencyRates(
      baseCurrency: 'EUR',
      updatedAt: '',
      rates: {
        'EUR': 1.0,
        'PLN': settings.defaultEurToPln,
        'CZK': 24.24,
        'HUF': 354.80,
      },
    );
  }

  static CurrencyRates resolve({
    required AsyncValue<CurrencyRates> ratesAsync,
    required AppSettings settings,
    CurrencyRates? repositoryFallback,
  }) {
    return ratesAsync.maybeWhen(
      data: (value) => value,
      orElse: () => repositoryFallback ?? settingsFallback(settings),
    );
  }

  static String formatStoredPln(
    double valuePln,
    String displayCurrency,
    CurrencyRates rates,
    BuildContext context,
  ) {
    try {
      return MoneyFormatter.formatMoneyFromPln(
        valuePln,
        displayCurrency,
        rates,
        context,
      );
    } catch (_) {
      return Formatters.formatPln(valuePln);
    }
  }

  static String formatAmountInDisplayCurrency({
    required double amount,
    required String sourceCurrency,
    required String displayCurrency,
    required CurrencyRates rates,
    required String fallbackLabel,
  }) {
    try {
      return MoneyFormatter.formatMoneyInDisplayCurrency(
        amount,
        sourceCurrency,
        displayCurrency,
        rates,
      );
    } catch (_) {
      return fallbackLabel;
    }
  }
}
