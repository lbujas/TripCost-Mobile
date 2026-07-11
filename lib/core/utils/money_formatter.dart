import 'package:flutter/material.dart';
import 'package:travel_cost_planner_europe/core/utils/formatters.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static double convertBetweenCurrencies(
    double amount,
    String fromCurrency,
    String toCurrency,
    CurrencyRates rates,
  ) {
    final from = fromCurrency.toUpperCase();
    final to = toCurrency.toUpperCase();
    if (from == to) {
      return amount;
    }

    final base = rates.baseCurrency.toUpperCase();
    final amountInBase = from == base ? amount : amount / rates.rateFor(from);
    return to == base ? amountInBase : amountInBase * rates.rateFor(to);
  }

  static String formatMoneyInDisplayCurrency(
    double amount,
    String sourceCurrency,
    String displayCurrency,
    CurrencyRates rates,
  ) {
    final converted = convertBetweenCurrencies(
      amount,
      sourceCurrency,
      displayCurrency,
      rates,
    );
    return formatMoney(converted, displayCurrency);
  }

  static double convertFromPln(
    double valuePln,
    String targetCurrency,
    CurrencyRates rates,
  ) {
    final normalized = targetCurrency.toUpperCase();
    if (normalized == 'PLN') {
      return valuePln;
    }

    final valueInEur = valuePln / rates.rateFor('PLN');
    return valueInEur * rates.rateFor(normalized);
  }

  static String formatMoney(double amount, String currencyCode) {
    final normalized = currencyCode.toUpperCase();

    return switch (normalized) {
      'EUR' => '${_formatDecimal(amount)} EUR',
      'PLN' => Formatters.formatPln(amount),
      'CZK' => '${_formatDecimal(amount)} CZK',
      'HUF' => '${amount.round()} HUF',
      _ => '${_formatDecimal(amount)} $normalized',
    };
  }

  static String formatMoneyFromPln(
    double valuePln,
    String targetCurrency,
    CurrencyRates rates,
    BuildContext context,
  ) {
    final converted = convertFromPln(valuePln, targetCurrency, rates);
    return formatMoney(converted, targetCurrency);
  }

  static String _formatDecimal(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final integerPart = parts.first;
    final fractionPart = parts.length > 1 ? parts[1] : '00';
    return '${_addThousandsSeparator(integerPart)},$fractionPart';
  }

  static String _addThousandsSeparator(String digits) {
    final isNegative = digits.startsWith('-');
    final normalized = isNegative ? digits.substring(1) : digits;
    final buffer = StringBuffer();

    for (var index = 0; index < normalized.length; index++) {
      if (index > 0 && (normalized.length - index) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(normalized[index]);
    }

    return isNegative ? '-${buffer.toString()}' : buffer.toString();
  }
}
