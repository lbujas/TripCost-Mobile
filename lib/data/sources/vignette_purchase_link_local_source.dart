import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/vignette_purchase_link.dart';

class VignettePurchaseLinkLocalSource {
  const VignettePurchaseLinkLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<VignettePurchaseLink>> getAllPurchaseLinks() async {
    final items = await _loader.loadJsonList(AssetPaths.vignettePurchaseLinks);
    return items
        .map(
          (item) => VignettePurchaseLink.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
