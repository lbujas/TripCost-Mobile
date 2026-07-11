import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/domain/models/app_statistics.dart';

class StatisticsLocalSource {
  StatisticsLocalSource(this._hiveService);

  static const String _statisticsKey = 'app_statistics';

  final HiveService _hiveService;

  Future<AppStatistics> getStatistics() async {
    final raw = _hiveService.statisticsBox.get(_statisticsKey);
    if (raw == null) {
      return AppStatistics.defaults();
    }

    return AppStatistics.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> saveStatistics(AppStatistics statistics) async {
    await _hiveService.statisticsBox.put(_statisticsKey, statistics.toJson());
  }
}
