import 'package:travel_cost_planner_europe/data/sources/route_distance_estimate_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/route_distance_estimate.dart';
import 'package:travel_cost_planner_europe/domain/repositories/route_distance_estimate_repository.dart';

class RouteDistanceEstimateRepositoryImpl
    implements RouteDistanceEstimateRepository {
  const RouteDistanceEstimateRepositoryImpl(this._localSource);

  final RouteDistanceEstimateLocalSource _localSource;

  static const Map<String, String> _regionHubDestinationIds = {
    'istria': 'pula',
    'kvarner': 'rijeka',
    'zadar': 'zadar',
    'sibenik': 'sibenik',
    'split': 'split',
    'makarska': 'makarska',
    'ploce': 'ploce',
    'dubrovnik': 'dubrovnik',
  };

  @override
  Future<List<RouteDistanceEstimate>> getAllEstimates() {
    return _localSource.getEstimates();
  }

  @override
  Future<double?> getEstimatedOneWayDistanceKm({
    required String originCityId,
    required String croatiaDestinationId,
    required String routeId,
    double destinationExtraDistanceKm = 0,
    double hubDestinationExtraDistanceKm = 0,
    double routeFallbackDistanceKm = 0,
  }) async {
    final estimates = await getAllEstimates();

    final exact = _findEstimate(
      estimates,
      originCityId: originCityId,
      croatiaDestinationId: croatiaDestinationId,
      routeId: routeId,
    );
    if (exact != null) {
      return exact.oneWayDistanceKm +
          (destinationExtraDistanceKm - hubDestinationExtraDistanceKm);
    }

    for (final hubDestinationId in _regionHubDestinationIds.values) {
      final hubEstimate = _findEstimate(
        estimates,
        originCityId: originCityId,
        croatiaDestinationId: hubDestinationId,
        routeId: routeId,
      );
      if (hubEstimate != null) {
        return hubEstimate.oneWayDistanceKm +
            (destinationExtraDistanceKm - hubDestinationExtraDistanceKm);
      }
    }

    if (routeFallbackDistanceKm > 0) {
      return routeFallbackDistanceKm + destinationExtraDistanceKm;
    }

    return null;
  }

  RouteDistanceEstimate? _findEstimate(
    List<RouteDistanceEstimate> estimates, {
    required String originCityId,
    required String croatiaDestinationId,
    required String routeId,
  }) {
    for (final estimate in estimates) {
      if (estimate.originCityId == originCityId &&
          estimate.croatiaDestinationId == croatiaDestinationId &&
          estimate.routeId == routeId) {
        return estimate;
      }
    }
    return null;
  }
}
