import 'package:travel_cost_planner_europe/data/sources/settings_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/repositories/settings_repository.dart';

/// Data-layer implementation of [SettingsRepository].
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localSource);

  final SettingsLocalSource _localSource;

  @override
  Future<AppSettings> getSettings() {
    return _localSource.getSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) {
    return _localSource.saveSettings(settings);
  }
}
