import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';

/// Contract for persisting user preferences.
abstract class SettingsRepository {
  Future<AppSettings> getSettings();

  Future<void> saveSettings(AppSettings settings);
}
