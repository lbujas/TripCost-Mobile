import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/ferry_price.dart';

/// Local data source for bundled Croatian ferry prices.
class FerryPricesLocalSource {
  const FerryPricesLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<FerryPrice>> getAll() async {
    final items = await _loader.loadJsonList(AssetPaths.ferryPricesHr);
    return items
        .map((item) => FerryPrice.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FerryPrice>> getForRoute(String routeId) async {
    final prices = await getAll();
    return prices.where((price) => price.routeId == routeId).toList();
  }

  Future<List<FerryPrice>> getForRouteAndVehicleType({
    required String routeId,
    required String vehicleTypeCode,
  }) async {
    final prices = await getAll();
    return prices
        .where(
          (price) =>
      price.routeId == routeId &&
          price.vehicleTypeCode == vehicleTypeCode,
    )
        .toList();
  }
}