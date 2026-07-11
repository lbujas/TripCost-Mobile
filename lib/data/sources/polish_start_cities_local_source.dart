import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/polish_voivodeship.dart';

class PolishStartCitiesLocalSource {
  const PolishStartCitiesLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<PolishVoivodeship>> loadVoivodeships() async {
    final json = await _loader.loadJsonMap(AssetPaths.polishStartCitiesByVoivodeship);
    return PolishStartCitiesByVoivodeship.fromJson(json).voivodeships;
  }
}
