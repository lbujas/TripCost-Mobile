import 'package:travel_cost_planner_europe/data/sources/route_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/route_option.dart';
import 'package:travel_cost_planner_europe/domain/repositories/route_repository.dart';

/// Data-layer implementation of [RouteRepository] using bundled JSON assets.
class RouteRepositoryImpl implements RouteRepository {
  const RouteRepositoryImpl(this._localSource);

  final RouteLocalSource _localSource;

  @override
  Future<List<RouteOption>> getAllRoutes() {
    return _localSource.getAllRoutes();
  }
}
