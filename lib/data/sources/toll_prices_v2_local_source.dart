import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_toll_price.dart';

/// Local data source for bundled v2 toll prices by vehicle category.
class TollPricesV2LocalSource {
  const TollPricesV2LocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<VehicleCategoryTollPrice>> getAll() async {
    final items = await _loader.loadJsonList(AssetPaths.tollPricesV2);
    return items
        .map(
          (item) =>
              VehicleCategoryTollPrice.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<VehicleCategoryTollPrice>> getForCountry(
    String countryCode,
  ) async {
    final normalizedCode = countryCode.toUpperCase();
    final prices = await getAll();
    return prices
        .where((price) => price.countryCode == normalizedCode)
        .toList();
  }

  Future<List<VehicleCategoryTollPrice>> getForCountryAndCategory({
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
