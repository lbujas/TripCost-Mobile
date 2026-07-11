import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';

class CurrencyRatesLocalSource {
  const CurrencyRatesLocalSource(this._loader);

  final JsonAssetLoader _loader;

  Future<CurrencyRates> getCurrencyRates() async {
    final json = await _loader.loadJsonMap(AssetPaths.currencyRates);
    return CurrencyRates.fromJson(json);
  }
}
