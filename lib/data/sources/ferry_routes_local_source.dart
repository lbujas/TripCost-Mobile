import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/ferry_route.dart';

/// Local data source for bundled Croatian ferry routes.
class FerryRoutesLocalSource {
  const FerryRoutesLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<FerryRoute>> getAll() async {
    final items = await _loader.loadJsonList(AssetPaths.ferryRoutesHr);
    return items
        .map((item) => FerryRoute.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FerryRoute>> getForCountry(String countryCode) async {
    final normalizedCode = countryCode.toUpperCase();
    final routes = await getAll();
    return routes
        .where((route) => route.countryCode == normalizedCode)
        .toList();
  }
}