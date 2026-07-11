import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_result.dart';

/// Local data source for saved trip results stored in Hive as JSON maps.
class TripLocalSource {
  TripLocalSource(this._hiveService);

  static const String _tripsKey = 'trips';

  final HiveService _hiveService;

  Future<List<TripResult>> getTrips() async {
    return _readTrips();
  }

  Future<void> saveTrips(List<TripResult> trips) async {
    final serialized = trips.map((trip) => trip.toJson()).toList();
    await _hiveService.tripsBox.put(_tripsKey, serialized);
  }

  Future<void> addTrip(TripResult trip) async {
    final trips = _readTrips();
    if (trip.id != null && trips.any((saved) => saved.id == trip.id)) {
      return;
    }
    trips.add(trip);
    await saveTrips(trips);
  }

  Future<void> deleteTrip(String id) async {
    final trips = _readTrips();
    trips.removeWhere((trip) => trip.id == id);
    await saveTrips(trips);
  }

  Future<void> clearTrips() async {
    await _hiveService.tripsBox.put(_tripsKey, <dynamic>[]);
  }

  List<TripResult> _readTrips() {
    final raw =
        _hiveService.tripsBox.get(_tripsKey, defaultValue: <dynamic>[]) as List;

    final trips = <TripResult>[];
    for (final item in raw) {
      try {
        trips.add(
          TripResult.fromJson(Map<String, dynamic>.from(item as Map)),
        );
      } catch (_) {
        continue;
      }
    }

    return trips;
  }
}
