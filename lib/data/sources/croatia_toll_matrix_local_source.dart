import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll_matrix_entry.dart';

class CroatiaTollMatrixLocalSource {
  const CroatiaTollMatrixLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<CroatiaTollMatrixEntry>> getAllEntries() async {
    final items = await _loader.loadJsonList(AssetPaths.croatiaTollMatrix);
    return items
        .map(
          (item) => CroatiaTollMatrixEntry.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
