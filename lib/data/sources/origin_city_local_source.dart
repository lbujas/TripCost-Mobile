import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/origin_city.dart';

class OriginCityLocalSource {
  const OriginCityLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<OriginCity>> getOriginCities() async {
    final items = await _loader.loadJsonList(AssetPaths.originCities);
    return items
        .map((item) => OriginCity.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
