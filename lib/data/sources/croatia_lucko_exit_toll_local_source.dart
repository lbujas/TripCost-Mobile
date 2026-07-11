import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_lucko_exit_toll.dart';

class CroatiaLuckoExitTollLocalSource {
  const CroatiaLuckoExitTollLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<CroatiaLuckoExitToll>> getAllExitTolls() async {
    final items = await _loader.loadJsonList(AssetPaths.croatiaLuckoExitTolls);
    return items
        .map(
          (item) => CroatiaLuckoExitToll.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
