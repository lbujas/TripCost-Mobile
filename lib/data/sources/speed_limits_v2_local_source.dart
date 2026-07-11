import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_speed_limit.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';

/// Local data source for bundled v2 speed limits by vehicle category.
class SpeedLimitsV2LocalSource {
  const SpeedLimitsV2LocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<VehicleCategorySpeedLimit>> getAll() async {
    final items = await _loader.loadJsonList(AssetPaths.speedLimitsV2);
    return items
        .map(
          (item) =>
              VehicleCategorySpeedLimit.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<VehicleCategorySpeedLimit>> getForCountry(
    String countryCode,
  ) async {
    final normalizedCode = countryCode.toUpperCase();
    final limits = await getAll();
    return limits
        .where((limit) => limit.countryCode == normalizedCode)
        .toList();
  }

  Future<VehicleCategorySpeedLimit?> getForCountryAndVehicleType({
    required String countryCode,
    required VehicleType vehicleType,
  }) async {
    final normalizedCode = countryCode.toUpperCase();
    final limits = await getAll();
    for (final limit in limits) {
      if (limit.countryCode == normalizedCode &&
          limit.vehicleType == vehicleType.storageValue) {
        return limit;
      }
    }
    return null;
  }

  Future<VehicleCategorySpeedLimit?> getForCountryAndCategory({
    required String countryCode,
    required String categoryCode,
  }) async {
    final normalizedCode = countryCode.toUpperCase();
    final limits = await getAll();
    for (final limit in limits) {
      if (limit.countryCode == normalizedCode &&
          limit.categoryCode == categoryCode) {
        return limit;
      }
    }
    return null;
  }
}
