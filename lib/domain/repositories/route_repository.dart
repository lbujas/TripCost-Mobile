import 'package:travel_cost_planner_europe/domain/models/route_option.dart';

/// Contract for fetching route options.
abstract class RouteRepository {
  Future<List<RouteOption>> getAllRoutes();
}
