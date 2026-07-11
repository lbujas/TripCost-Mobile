import 'package:travel_cost_planner_europe/data/sources/vignette_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/vignette.dart';
import 'package:travel_cost_planner_europe/domain/repositories/vignette_repository.dart';

/// Data-layer implementation of [VignetteRepository] using bundled JSON assets.
class VignetteRepositoryImpl implements VignetteRepository {
  const VignetteRepositoryImpl(this._localSource);

  final VignetteLocalSource _localSource;

  @override
  Future<List<Vignette>> getVignettesForCountries(
    List<String> countryCodes,
  ) {
    return _localSource.getVignettesForCountries(countryCodes);
  }
}
