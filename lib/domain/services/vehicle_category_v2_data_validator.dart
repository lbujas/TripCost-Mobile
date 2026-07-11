import 'package:travel_cost_planner_europe/domain/models/vehicle_category_speed_limit.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_toll_price.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_vignette_price.dart';
import 'package:travel_cost_planner_europe/domain/services/vehicle_category_mapping_service.dart';

/// Validates v2 pricing/speed-limit rows against known country vehicle categories.
class VehicleCategoryV2DataValidator {
  const VehicleCategoryV2DataValidator(this._mappingService);

  final VehicleCategoryMappingService _mappingService;

  /// Returns true when [categoryCode] is used by at least one [VehicleType] in
  /// [countryCode] according to [VehicleCategoryMappingService].
  bool isKnownCategory({
    required String countryCode,
    required String categoryCode,
  }) {
    try {
      final categories = _mappingService.categoriesForCountry(countryCode);
      return categories.any((category) => category.categoryCode == categoryCode);
    } on ArgumentError {
      return false;
    }
  }

  List<String> validateVignettePrices(List<VehicleCategoryVignettePrice> prices) {
    return _validateVignette(
      prices,
      (price) => (price.countryCode, price.categoryCode),
      'vignette',
    );
  }

  List<String> validateTollPrices(List<VehicleCategoryTollPrice> prices) {
    return _validate(
      prices,
      (price) => (price.countryCode, price.categoryCode),
      'toll',
    );
  }

  List<String> validateSpeedLimits(List<VehicleCategorySpeedLimit> limits) {
    return _validate(
      limits,
      (limit) => (limit.countryCode, limit.categoryCode),
      'speed limit',
    );
  }

  List<String> _validateVignette<T>(
    List<T> items,
    (String, String) Function(T item) countryAndCategory,
    String label,
  ) {
    final errors = <String>[];
    for (final item in items) {
      final (countryCode, categoryCode) = countryAndCategory(item);
      if (!_mappingService.isKnownVignetteCategory(
        countryCode: countryCode,
        categoryCode: categoryCode,
      )) {
        errors.add(
          'Unknown $label category "$categoryCode" for country $countryCode',
        );
      }
    }
    return errors;
  }

  List<String> _validate<T>(
    List<T> items,
    (String, String) Function(T item) countryAndCategory,
    String label,
  ) {
    final errors = <String>[];
    for (final item in items) {
      final (countryCode, categoryCode) = countryAndCategory(item);
      if (!isKnownCategory(
        countryCode: countryCode,
        categoryCode: categoryCode,
      )) {
        errors.add(
          'Unknown $label category "$categoryCode" for country $countryCode',
        );
      }
    }
    return errors;
  }
}
