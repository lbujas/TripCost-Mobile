import 'package:travel_cost_planner_europe/domain/models/toll.dart';

/// Contract for retrieving toll segments along a route.
abstract class TollRepository {
  Future<List<Toll>> getTollsForRoute(String routeId);
}
