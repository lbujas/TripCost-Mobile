import 'package:travel_cost_planner_europe/domain/models/trip_result.dart';

/// Contract for persisting saved trip cost results.
abstract class TripRepository {
  Future<List<TripResult>> getSavedTrips();

  Future<void> saveTrip(TripResult result);

  Future<void> deleteTrip(String id);

  Future<void> clearHistory();
}
