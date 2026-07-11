import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';

class CurrencyRatesCacheSource {
  CurrencyRatesCacheSource(this._hiveService);

  static const _dataKey = 'currency_rates_cache';
  static const _savedAtKey = 'currency_rates_cache_saved_at';

  final HiveService _hiveService;

  Future<void> save(CurrencyRates rates) async {
    final box = _hiveService.settingsBox;
    await box.put(_dataKey, rates.toJson());
    await box.put(_savedAtKey, DateTime.now().toIso8601String());
  }

  Future<CurrencyRates?> loadIfFresh(Duration ttl) async {
    final savedAtRaw = _hiveService.settingsBox.get(_savedAtKey) as String?;
    final data = _hiveService.settingsBox.get(_dataKey);
    if (savedAtRaw == null || data is! Map) {
      return null;
    }

    final savedAt = DateTime.tryParse(savedAtRaw);
    if (savedAt == null || DateTime.now().difference(savedAt) > ttl) {
      return null;
    }

    return CurrencyRates.fromJson(Map<String, dynamic>.from(data));
  }

  Future<CurrencyRates?> load() async {
    final data = _hiveService.settingsBox.get(_dataKey);
    if (data is! Map) {
      return null;
    }

    return CurrencyRates.fromJson(Map<String, dynamic>.from(data));
  }
}
