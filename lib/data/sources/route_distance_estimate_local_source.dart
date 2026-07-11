import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/route_distance_estimate.dart';

class RouteDistanceEstimateLocalSource {
  const RouteDistanceEstimateLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<RouteDistanceEstimate>> getEstimates() async {
    final items = await _loader.loadJsonList(AssetPaths.routeDistanceEstimates);
    return items
        .map(
          (item) =>
              RouteDistanceEstimate.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
