import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';

/// Local data source for app settings stored in Hive as a JSON map.
class SettingsLocalSource {
  SettingsLocalSource(this._hiveService);

  static const String _settingsKey = 'app_settings';

  final HiveService _hiveService;

  Future<AppSettings> getSettings() async {
    final raw = _hiveService.settingsBox.get(_settingsKey);
    if (raw == null) {
      return AppSettings.defaults();
    }

    try {
      return AppSettings.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (_) {
      return AppSettings.defaults();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _hiveService.settingsBox.put(_settingsKey, settings.toJson());
  }
}
