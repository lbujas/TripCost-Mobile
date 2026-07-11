import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:travel_cost_planner_europe/core/constants/api_constants.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';

class CurrencyRatesRemoteSource {
  const CurrencyRatesRemoteSource();

  Future<CurrencyRates> fetchCurrencyRates() async {
    final response = await http
        .get(Uri.parse(ApiConstants.exchangeRatesUrl))
        .timeout(ApiConstants.requestTimeout);

    if (response.statusCode != 200) {
      throw HttpException('Exchange rates request failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Exchange rates response must be a JSON object');
    }

    return CurrencyRates.fromJson(decoded);
  }
}

class HttpException implements Exception {
  const HttpException(this.message);

  final String message;

  @override
  String toString() => message;
}
