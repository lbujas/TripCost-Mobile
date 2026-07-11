import 'package:travel_cost_planner_europe/domain/models/origin_city.dart';

abstract class OriginCityRepository {
  Future<List<OriginCity>> getAllOriginCities();

  Future<OriginCity?> getOriginCityById(String id);
}
