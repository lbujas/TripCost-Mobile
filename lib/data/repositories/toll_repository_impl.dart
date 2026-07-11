import 'package:travel_cost_planner_europe/data/sources/toll_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/toll.dart';
import 'package:travel_cost_planner_europe/domain/repositories/toll_repository.dart';

/// Data-layer implementation of [TollRepository] using bundled JSON assets.
class TollRepositoryImpl implements TollRepository {
  const TollRepositoryImpl(this._localSource);

  final TollLocalSource _localSource;

  @override
  Future<List<Toll>> getTollsForRoute(String routeId) {
    return _localSource.getTollsForRoute(routeId);
  }
}
