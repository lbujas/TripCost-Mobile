import 'package:travel_cost_planner_europe/domain/models/route_distance_estimate.dart';

abstract class RouteDistanceEstimateRepository {
  Future<List<RouteDistanceEstimate>> getAllEstimates();

  Future<double?> getEstimatedOneWayDistanceKm({
    required String originCityId,
    required String croatiaDestinationId,
    required String routeId,
    double destinationExtraDistanceKm = 0,
    double hubDestinationExtraDistanceKm = 0,
    double routeFallbackDistanceKm = 0,
  });
}
