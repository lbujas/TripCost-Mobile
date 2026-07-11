import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';

/// Official toll/vignette category for a vehicle type in a specific country.
///
/// Used by [VehicleCategoryMappingService] to translate app-level [VehicleType]
/// values into country-specific pricing categories (future vignette/toll logic).
class CountryVehicleCategory {
  const CountryVehicleCategory({
    required this.countryCode,
    required this.categoryCode,
    required this.displayName,
    required this.appliesToVehicleType,
    this.ruleDescription,
    this.vignetteExempt = false,
  });

  final String countryCode;
  final String categoryCode;
  final String displayName;
  final VehicleType appliesToVehicleType;

  /// Optional rule hint for edge cases not yet modeled in calculations.
  final String? ruleDescription;

  /// When true, no motorway vignette category applies for this mapping.
  final bool vignetteExempt;
}
