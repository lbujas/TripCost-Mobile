import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:travel_cost_planner_europe/core/constants/api_constants.dart';
import 'package:travel_cost_planner_europe/domain/models/fuel_prices_snapshot.dart';

class FuelPriceRemoteSource {
  const FuelPriceRemoteSource();

  Future<FuelPricesSnapshot> fetchFuelPrices() async {
    final response = await http
        .get(Uri.parse(ApiConstants.fuelPricesUrl))
        .timeout(ApiConstants.requestTimeout);

    if (response.statusCode != 200) {
      throw FuelPriceFetchException(
        'Fuel prices request failed: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Fuel prices response must be a JSON object');
    }

    return FuelPricesSnapshot.fromJson(decoded);
  }
}

class FuelPriceFetchException implements Exception {
  const FuelPriceFetchException(this.message);

  final String message;

  @override
  String toString() => message;
}
