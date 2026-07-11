import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_vignette_price.dart';

/// Local data source for bundled v2 vignette prices by vehicle category.
class VignettePricesV2LocalSource {
  const VignettePricesV2LocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<VehicleCategoryVignettePrice>> getAll() async {
    final items = await _loader.loadJsonList(AssetPaths.vignettePricesV2);
    return items
        .map(
          (item) =>
              VehicleCategoryVignettePrice.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<VehicleCategoryVignettePrice>> getForCountry(
    String countryCode,
  ) async {
    final normalizedCode = countryCode.toUpperCase();
    final prices = await getAll();
    return prices
        .where((price) => price.countryCode == normalizedCode)
        .toList();
  }

  Future<List<VehicleCategoryVignettePrice>> getForCountryAndCategory({
    required String countryCode,
    required String categoryCode,
  }) async {
    final normalizedCode = countryCode.toUpperCase();
    final prices = await getAll();
    return prices
        .where(
          (price) =>
              price.countryCode == normalizedCode &&
              price.categoryCode == categoryCode,
        )
        .toList();
  }
}
