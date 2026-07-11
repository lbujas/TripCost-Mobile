import 'package:travel_cost_planner_europe/domain/models/app_statistics.dart';

abstract class StatisticsRepository {
  Future<AppStatistics> getStatistics();

  Future<void> incrementCalculationsCount();

  Future<void> incrementSavedTripsCount();
}
