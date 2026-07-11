import 'package:travel_cost_planner_europe/domain/models/vignette.dart';

/// Contract for retrieving vignette requirements and prices.
abstract class VignetteRepository {
  Future<List<Vignette>> getVignettesForCountries(List<String> countryCodes);
}
