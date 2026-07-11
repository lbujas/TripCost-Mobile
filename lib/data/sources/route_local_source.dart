import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/route_option.dart';

/// Local data source for bundled route options.
class RouteLocalSource {
  const RouteLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<RouteOption>> getAllRoutes() async {
    final items = await _loader.loadJsonList(AssetPaths.routes);
    return items
        .map((item) => RouteOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
