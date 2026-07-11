import 'package:travel_cost_planner_europe/domain/models/fuel_price.dart';
import 'package:travel_cost_planner_europe/domain/models/fuel_prices_snapshot.dart';

/// Contract for retrieving fuel prices by country.
abstract class FuelPriceRepository {
  Future<FuelPrice?> getFuelPrice({
    required String countryCode,
    required String fuelType,
  });

  Future<List<FuelPrice>> getFuelPricesForCountries({
    required List<String> countryCodes,
    required String fuelType,
  });

  Future<FuelPricesSnapshot> getFuelPricesSnapshot();
}
