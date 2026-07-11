import 'package:travel_cost_planner_europe/domain/models/vehicle_category_speed_limit.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';
import 'package:travel_cost_planner_europe/domain/services/vehicle_category_mapping_service.dart';

/// Describes one required speed-limit row for a country and vehicle type.
class SpeedLimitV2Requirement {
  const SpeedLimitV2Requirement({
    required this.countryCode,
    required this.vehicleType,
  });

  final String countryCode;
  final VehicleType vehicleType;

  String get key => '$countryCode:${vehicleType.storageValue}';

  @override
  String toString() => '$countryCode ${vehicleType.storageValue}';
}

/// Coverage report for speed_limits_v2.json.
class SpeedLimitsV2CoverageReport {
  const SpeedLimitsV2CoverageReport({
    required this.present,
    required this.missing,
    required this.categoryMismatches,
  });

  final List<SpeedLimitV2Requirement> present;
  final List<SpeedLimitV2Requirement> missing;
  final List<String> categoryMismatches;

  bool get hasFullCoverage =>
      missing.isEmpty && categoryMismatches.isEmpty;
}

/// Validates speed_limits_v2 coverage for route countries and vehicle types.
class SpeedLimitsV2Validator {
  const SpeedLimitsV2Validator(this._mappingService);

  final VehicleCategoryMappingService _mappingService;

  static const List<String> activeCountryCodes =
      VehicleCategoryMappingService.supportedCountryCodes;

  SpeedLimitsV2CoverageReport validateCoverage(
    List<VehicleCategorySpeedLimit> limits,
  ) {
    final indexed = <String, VehicleCategorySpeedLimit>{};
    for (final limit in limits) {
      indexed[_key(limit.countryCode, limit.vehicleType)] = limit;
    }

    final present = <SpeedLimitV2Requirement>[];
    final missing = <SpeedLimitV2Requirement>[];
    final categoryMismatches = <String>[];

    for (final countryCode in activeCountryCodes) {
      for (final vehicleType in VehicleType.selectableValues) {
        final requirement = SpeedLimitV2Requirement(
          countryCode: countryCode,
          vehicleType: vehicleType,
        );
        final limit = indexed[_key(countryCode, vehicleType.storageValue)];

        if (limit == null ||
            limit.city <= 0 ||
            limit.outsideCity <= 0 ||
            limit.expressway <= 0 ||
            limit.motorway <= 0) {
          missing.add(requirement);
          continue;
        }

        final expectedCategory = _mappingService
            .getCategoryFor(
              countryCode: countryCode,
              vehicleType: vehicleType,
            )
            .categoryCode;
        if (limit.categoryCode != expectedCategory) {
          categoryMismatches.add(
            '$requirement expected category $expectedCategory but found '
            '${limit.categoryCode}',
          );
        }

        present.add(requirement);
      }
    }

    return SpeedLimitsV2CoverageReport(
      present: present,
      missing: missing,
      categoryMismatches: categoryMismatches,
    );
  }

  static String _key(String countryCode, String vehicleType) {
    return '${countryCode.toUpperCase()}|$vehicleType';
  }
}
