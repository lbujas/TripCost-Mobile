/// Remote API configuration constants.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://57.128.246.44:8002';
  static const String exchangeRatesPath = '/api/exchange-rates';
  static const String exchangeRatesUrl = '$baseUrl$exchangeRatesPath';
  static const String fuelPricesPath = '/api/fuel-prices';
  static const String fuelPricesUrl = '$baseUrl$fuelPricesPath';

  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration exchangeRatesCacheTtl = Duration(hours: 24);
  static const Duration fuelPricesCacheTtl = Duration(hours: 24);
}
