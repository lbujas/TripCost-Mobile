import 'package:flutter/foundation.dart';
import 'package:travel_cost_planner_europe/core/utils/money_formatter.dart';
import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/models/car_fuel_type.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';
import 'package:travel_cost_planner_europe/domain/models/fuel_prices_snapshot.dart';

class RouteFuelPriceService {
  const RouteFuelPriceService();

  String backendFieldForCar(Car car) {
    return CarFuelType.fromStorage(car.fuelType).storageValue;
  }

  double resolveAverageFuelPricePln({
    required List<String> countryCodes,
    required Car car,
    required FuelPricesSnapshot snapshot,
    required CurrencyRates rates,
    required double fallbackFuelPricePln,
  }) {
    final backendField = backendFieldForCar(car);
    debugPrint(
      'RouteFuelPriceService: selected car fuel type=${car.fuelType}, '
      'mapped backend field=$backendField',
    );

    final pricesEurByCountry = <String, double>{};
    for (final countryCode in countryCodes) {
      final priceEur = snapshot.priceForCountry(
        countryCode: countryCode,
        backendField: backendField,
      );
      if (priceEur != null) {
        pricesEurByCountry[countryCode.toUpperCase()] = priceEur;
      }
    }

    debugPrint(
      'RouteFuelPriceService: country prices used (EUR/l)=$pricesEurByCountry',
    );

    if (pricesEurByCountry.isEmpty) {
      debugPrint(
        'RouteFuelPriceService: using fallback fuel price PLN/l=$fallbackFuelPricePln',
      );
      return fallbackFuelPricePln;
    }

    final averageEur = pricesEurByCountry.values.reduce((a, b) => a + b) /
        pricesEurByCountry.length;
    final averagePln = MoneyFormatter.convertBetweenCurrencies(
      averageEur,
      'EUR',
      'PLN',
      rates,
    );

    debugPrint(
      'RouteFuelPriceService: calculated average fuel price PLN/l=$averagePln',
    );

    return averagePln;
  }
}
