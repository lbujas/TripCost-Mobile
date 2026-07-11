import 'package:travel_cost_planner_europe/data/sources/trip_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_result.dart';
import 'package:travel_cost_planner_europe/domain/repositories/trip_repository.dart';

/// Data-layer implementation of [TripRepository].
class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl(this._localSource);

  final TripLocalSource _localSource;

  @override
  Future<List<TripResult>> getSavedTrips() async {
    final trips = await _localSource.getTrips();
    trips.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return trips;
  }

  @override
  Future<void> saveTrip(TripResult result) async {
    final trip = result.copyWith(
      id: result.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: result.createdAt ?? DateTime.now(),
    );
    await _localSource.addTrip(trip);
  }

  @override
  Future<void> deleteTrip(String id) async {
    await _localSource.deleteTrip(id);
  }

  @override
  Future<void> clearHistory() async {
    await _localSource.clearTrips();
  }
}
