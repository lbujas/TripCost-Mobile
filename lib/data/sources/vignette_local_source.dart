import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/vignette.dart';

/// Local data source for bundled vignette prices.
class VignetteLocalSource {
  const VignetteLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<List<Vignette>> getAllVignettes() async {
    final items = await _loader.loadJsonList(AssetPaths.vignettePrices);
    return items
        .map((item) => Vignette.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Vignette>> getVignettesForCountries(
    List<String> countryCodes,
  ) async {
    final vignettes = await getAllVignettes();
    final normalizedCodes =
        countryCodes.map((code) => code.toUpperCase()).toSet();

    return vignettes
        .where((vignette) => normalizedCodes.contains(vignette.countryCode))
        .toList();
  }
}
