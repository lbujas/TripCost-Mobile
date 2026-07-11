import 'package:travel_cost_planner_europe/domain/models/croatia_region.dart';

abstract class CroatiaRegionRepository {
  Future<List<CroatiaRegion>> getAllRegions();

  Future<CroatiaRegion?> getRegionById(String id);
}
