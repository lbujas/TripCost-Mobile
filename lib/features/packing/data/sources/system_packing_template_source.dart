import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';

/// Loads bundled system packing templates from assets.
class SystemPackingTemplateSource {
  const SystemPackingTemplateSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<PackingTemplate>> getAll() async {
    final items = await _loader.loadJsonList(AssetPaths.packingTemplates);
    final templates = <PackingTemplate>[];

    for (final entry in items) {
      if (entry is! Map) {
        continue;
      }

      try {
        templates.add(
          PackingTemplate.fromJson(Map<String, dynamic>.from(entry)),
        );
      } catch (_) {
        continue;
      }
    }

    return templates;
  }
}
