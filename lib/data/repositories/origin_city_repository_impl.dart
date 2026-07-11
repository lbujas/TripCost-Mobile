import 'package:travel_cost_planner_europe/data/sources/origin_city_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/origin_city.dart';
import 'package:travel_cost_planner_europe/domain/repositories/origin_city_repository.dart';

class OriginCityRepositoryImpl implements OriginCityRepository {
  const OriginCityRepositoryImpl(this._localSource);

  final OriginCityLocalSource _localSource;

  @override
  Future<List<OriginCity>> getAllOriginCities() {
    return _localSource.getOriginCities();
  }

  @override
  Future<OriginCity?> getOriginCityById(String id) async {
    final cities = await getAllOriginCities();
    for (final city in cities) {
      if (city.id == id) {
        return city;
      }
    }
    return null;
  }
}
