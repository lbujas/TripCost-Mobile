class CurrencyRates {
  const CurrencyRates({
    required this.baseCurrency,
    required this.updatedAt,
    required this.rates,
  });

  final String baseCurrency;
  final String updatedAt;
  final Map<String, double> rates;

  factory CurrencyRates.fromJson(Map<String, dynamic> json) {
    final ratesJson = json['rates'] as Map<String, dynamic>;
    final baseCurrency =
        (json['baseCurrency'] ?? json['base']) as String? ?? 'EUR';
    final updatedAt = json['updatedAt'] as String? ?? '';
    return CurrencyRates(
      baseCurrency: baseCurrency,
      updatedAt: updatedAt,
      rates: ratesJson.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseCurrency': baseCurrency,
      'updatedAt': updatedAt,
      'rates': rates,
    };
  }

  double rateFor(String currencyCode) {
    final rate = rates[currencyCode.toUpperCase()];
    if (rate == null) {
      throw ArgumentError.value(currencyCode, 'currencyCode', 'Unknown currency');
    }
    return rate;
  }
}
