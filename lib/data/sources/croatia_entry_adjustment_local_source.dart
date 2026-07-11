import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_entry_adjustment.dart';

class CroatiaEntryAdjustmentLocalSource {
  const CroatiaEntryAdjustmentLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<CroatiaEntryAdjustment>> getAllAdjustments() async {
    final items = await _loader.loadJsonList(AssetPaths.croatiaEntryAdjustments);
    return items
        .map(
          (item) => CroatiaEntryAdjustment.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
