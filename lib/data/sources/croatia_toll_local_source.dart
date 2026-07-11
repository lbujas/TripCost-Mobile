import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll.dart';

class CroatiaTollLocalSource {
  const CroatiaTollLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<CroatiaToll>> getTolls() async {
    final items = await _loader.loadJsonList(AssetPaths.croatiaTolls);
    return items
        .map((item) => CroatiaToll.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
