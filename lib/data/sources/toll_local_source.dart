import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/toll.dart';

/// Local data source for bundled toll data.
class TollLocalSource {
  const TollLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<Toll>> getAllTolls() async {
    final items = await _loader.loadJsonList(AssetPaths.tolls);
    return items
        .map((item) => Toll.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Toll>> getTollsForRoute(String routeId) async {
    final tolls = await getAllTolls();
    return tolls.where((toll) => toll.routeId == routeId).toList();
  }
}
