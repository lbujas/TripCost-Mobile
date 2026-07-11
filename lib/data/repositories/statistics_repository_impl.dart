import 'package:travel_cost_planner_europe/data/sources/statistics_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/app_statistics.dart';
import 'package:travel_cost_planner_europe/domain/repositories/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl(this._localSource);

  final StatisticsLocalSource _localSource;

  @override
  Future<AppStatistics> getStatistics() {
    return _localSource.getStatistics();
  }

  @override
  Future<void> incrementCalculationsCount() async {
    final current = await _localSource.getStatistics();
    await _localSource.saveStatistics(
      current.copyWith(calculationsCount: current.calculationsCount + 1),
    );
  }

  @override
  Future<void> incrementSavedTripsCount() async {
    final current = await _localSource.getStatistics();
    await _localSource.saveStatistics(
      current.copyWith(savedTripsCount: current.savedTripsCount + 1),
    );
  }
}
