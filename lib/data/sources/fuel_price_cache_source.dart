import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/domain/models/fuel_prices_snapshot.dart';

class FuelPriceCacheSource {
  FuelPriceCacheSource(this._hiveService);

  static const _dataKey = 'fuel_prices_cache';
  static const _savedAtKey = 'fuel_prices_cache_saved_at';

  final HiveService _hiveService;

  Future<void> save(FuelPricesSnapshot snapshot) async {
    final box = _hiveService.settingsBox;
    await box.put(_dataKey, snapshot.toJson());
    await box.put(_savedAtKey, DateTime.now().toIso8601String());
  }

  Future<FuelPricesSnapshot?> loadIfFresh(Duration ttl) async {
    final savedAtRaw = _hiveService.settingsBox.get(_savedAtKey) as String?;
    final data = _hiveService.settingsBox.get(_dataKey);
    if (savedAtRaw == null || data is! Map) {
      return null;
    }

    final savedAt = DateTime.tryParse(savedAtRaw);
    if (savedAt == null || DateTime.now().difference(savedAt) > ttl) {
      return null;
    }

    return FuelPricesSnapshot.fromJson(Map<String, dynamic>.from(data));
  }

  Future<FuelPricesSnapshot?> load() async {
    final data = _hiveService.settingsBox.get(_dataKey);
    if (data is! Map) {
      return null;
    }

    return FuelPricesSnapshot.fromJson(Map<String, dynamic>.from(data));
  }
}
