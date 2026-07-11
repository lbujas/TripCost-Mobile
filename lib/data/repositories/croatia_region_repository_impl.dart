import 'package:travel_cost_planner_europe/data/sources/croatia_region_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_region.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_region_repository.dart';

class CroatiaRegionRepositoryImpl implements CroatiaRegionRepository {
  CroatiaRegionRepositoryImpl(this._localSource);

  final CroatiaRegionLocalSource _localSource;

  @override
  Future<List<CroatiaRegion>> getAllRegions() {
    return _localSource.getRegions();
  }

  @override
  Future<CroatiaRegion?> getRegionById(String id) async {
    final regions = await getAllRegions();
    for (final region in regions) {
      if (region.id == id) {
        return region;
      }
    }
    return null;
  }
}
