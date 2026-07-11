import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_destination.dart';

class CroatiaDestinationLocalSource {
  CroatiaDestinationLocalSource(this._loader, this._hiveService);

  static const String _recentDestinationsKey = 'recent_croatia_destinations';

  final JsonAssetLoader _loader;
  final HiveService _hiveService;

  Future<List<CroatiaDestination>> getDestinations() async {
    final items = await _loader.loadJsonList(AssetPaths.croatiaDestinations);
    return items
        .map(
          (item) => CroatiaDestination.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<String>> getRecentDestinationIds() async {
    final raw = _hiveService.settingsBox.get(
      _recentDestinationsKey,
      defaultValue: <dynamic>[],
    ) as List;
    return raw.map((item) => item as String).toList();
  }

  Future<void> addRecentDestination(String destinationId) async {
    final recent = await getRecentDestinationIds();
    recent.remove(destinationId);
    recent.insert(0, destinationId);
    final trimmed = recent.take(5).toList();
    await _hiveService.settingsBox.put(_recentDestinationsKey, trimmed);
  }
}
