import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/fuel_price.dart';

/// Local data source for bundled fuel prices.
class FuelPriceLocalSource {
  const FuelPriceLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<FuelPrice>> getAllFuelPrices() async {
    final items = await _loader.loadJsonList(AssetPaths.fuelPrices);
    return items
        .map((item) => FuelPrice.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FuelPrice?> getFuelPrice({
    required String countryCode,
    required String fuelType,
  }) async {
    final prices = await getAllFuelPrices();
    final normalizedCountry = countryCode.toUpperCase();
    final normalizedFuelType = fuelType.toLowerCase();

    for (final price in prices) {
      if (price.countryCode == normalizedCountry &&
          price.fuelType.toLowerCase() == normalizedFuelType) {
        return price;
      }
    }

    return null;
  }

  Future<List<FuelPrice>> getFuelPricesForCountries({
    required List<String> countryCodes,
    required String fuelType,
  }) async {
    final prices = await getAllFuelPrices();
    final normalizedCodes =
        countryCodes.map((code) => code.toUpperCase()).toSet();
    final normalizedFuelType = fuelType.toLowerCase();

    return prices
        .where(
          (price) =>
              normalizedCodes.contains(price.countryCode) &&
              price.fuelType.toLowerCase() == normalizedFuelType,
        )
        .toList();
  }
}
