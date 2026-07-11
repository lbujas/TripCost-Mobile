import 'package:travel_cost_planner_europe/domain/models/country_vehicle_category.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';

/// Maps app-level [VehicleType] values to country-specific toll/vignette categories.
class VehicleCategoryMappingService {
  const VehicleCategoryMappingService();

  static const List<String> supportedCountryCodes = [
    'PL',
    'CZ',
    'SK',
    'HU',
    'AT',
    'SI',
    'HR',
    'DE',
  ];

  static const Map<String, Map<VehicleType, CountryVehicleCategory>> _mappings = {
    'PL': _polandMappings,
    'CZ': _czechiaMappings,
    'SK': _slovakiaMappings,
    'HU': _hungaryMappings,
    'AT': _austriaMappings,
    'SI': _sloveniaMappings,
    'HR': _croatiaMappings,
    'DE': _germanyMappings,
  };

  /// Returns the country-specific category for [countryCode] and [vehicleType].
  ///
  /// [countryCode] is case-insensitive (e.g. `cz` or `CZ`).
  CountryVehicleCategory getCategoryFor({
    required String countryCode,
    required VehicleType vehicleType,
  }) {
    final normalizedCountry = countryCode.toUpperCase();
    final countryMappings = _mappings[normalizedCountry];
    if (countryMappings == null) {
      throw ArgumentError.value(
        countryCode,
        'countryCode',
        'Unsupported country code. Supported: $supportedCountryCodes',
      );
    }

    final category = countryMappings[vehicleType];
    if (category == null) {
      throw ArgumentError.value(
        vehicleType,
        'vehicleType',
        'No category mapping for $normalizedCountry / ${vehicleType.storageValue}',
      );
    }

    return category;
  }

  /// Billing category code(s) for vignette price lookup in v2 data.
  ///
  /// Returns an empty list when the vehicle type is vignette-exempt for the
  /// country. Hungary passenger car with trailer requires both D1 and U.
  List<String> vignetteBillingCategoryCodes({
    required String countryCode,
    required VehicleType vehicleType,
  }) {
    final normalizedCountry = countryCode.toUpperCase();
    final mapping = getCategoryFor(
      countryCode: normalizedCountry,
      vehicleType: vehicleType,
    );

    if (mapping.vignetteExempt) {
      return const [];
    }

    if (normalizedCountry == 'HU' &&
        vehicleType == VehicleType.passengerCarWithTrailer) {
      return const ['D1', 'U'];
    }

    return [mapping.categoryCode];
  }

  /// Whether [categoryCode] is used by at least one [VehicleType] in [countryCode].
  bool isKnownCategory({
    required String countryCode,
    required String categoryCode,
  }) {
    try {
      final categories = categoriesForCountry(countryCode);
      return categories.any((category) => category.categoryCode == categoryCode);
    } on ArgumentError {
      return false;
    }
  }

  /// Whether [categoryCode] is a known vignette billing code for [countryCode].
  bool isKnownVignetteCategory({
    required String countryCode,
    required String categoryCode,
  }) {
    final normalizedCountry = countryCode.toUpperCase();
    if (normalizedCountry == 'HU' && categoryCode == 'U') {
      return true;
    }

    return isKnownCategory(
      countryCode: normalizedCountry,
      categoryCode: categoryCode,
    );
  }

  /// All category mappings for a country (one entry per [VehicleType]).
  List<CountryVehicleCategory> categoriesForCountry(String countryCode) {
    final normalizedCountry = countryCode.toUpperCase();
    final countryMappings = _mappings[normalizedCountry];
    if (countryMappings == null) {
      throw ArgumentError.value(
        countryCode,
        'countryCode',
        'Unsupported country code. Supported: $supportedCountryCodes',
      );
    }

    return VehicleType.selectableValues
        .map((type) => countryMappings[type]!)
        .toList(growable: false);
  }
}

const Map<VehicleType, CountryVehicleCategory> _polandMappings = {
  VehicleType.motorcycle: CountryVehicleCategory(
    countryCode: 'PL',
    categoryCode: 'exempt',
    displayName: 'No motorway vignette',
    appliesToVehicleType: VehicleType.motorcycle,
    ruleDescription: 'Poland does not use motorway vignettes for this vehicle type.',
    vignetteExempt: true,
  ),
  VehicleType.passengerCar: CountryVehicleCategory(
    countryCode: 'PL',
    categoryCode: 'exempt',
    displayName: 'No motorway vignette',
    appliesToVehicleType: VehicleType.passengerCar,
    ruleDescription: 'Poland does not use motorway vignettes for this vehicle type.',
    vignetteExempt: true,
  ),
  VehicleType.passengerCarWithTrailer: CountryVehicleCategory(
    countryCode: 'PL',
    categoryCode: 'exempt',
    displayName: 'No motorway vignette',
    appliesToVehicleType: VehicleType.passengerCarWithTrailer,
    ruleDescription: 'Poland does not use motorway vignettes for this vehicle type.',
    vignetteExempt: true,
  ),
  VehicleType.camper: CountryVehicleCategory(
    countryCode: 'PL',
    categoryCode: 'exempt',
    displayName: 'No motorway vignette',
    appliesToVehicleType: VehicleType.camper,
    ruleDescription: 'Poland does not use motorway vignettes for this vehicle type.',
    vignetteExempt: true,
  ),
  VehicleType.vanUpTo35t: CountryVehicleCategory(
    countryCode: 'PL',
    categoryCode: 'exempt',
    displayName: 'No motorway vignette',
    appliesToVehicleType: VehicleType.vanUpTo35t,
    ruleDescription: 'Poland does not use motorway vignettes for this vehicle type.',
    vignetteExempt: true,
  ),
};

const Map<VehicleType, CountryVehicleCategory> _czechiaMappings = {
  VehicleType.motorcycle: CountryVehicleCategory(
    countryCode: 'CZ',
    categoryCode: 'exempt',
    displayName: 'Exempt (no vignette)',
    appliesToVehicleType: VehicleType.motorcycle,
    vignetteExempt: true,
  ),
  VehicleType.passengerCar: CountryVehicleCategory(
    countryCode: 'CZ',
    categoryCode: 'vehicle_up_to_3_5t',
    displayName: 'Vehicle up to 3.5 t',
    appliesToVehicleType: VehicleType.passengerCar,
  ),
  VehicleType.passengerCarWithTrailer: CountryVehicleCategory(
    countryCode: 'CZ',
    categoryCode: 'vehicle_up_to_3_5t',
    displayName: 'Vehicle up to 3.5 t',
    appliesToVehicleType: VehicleType.passengerCarWithTrailer,
    ruleDescription:
        'Trailer does not require a separate Czech motorway vignette.',
  ),
  VehicleType.camper: CountryVehicleCategory(
    countryCode: 'CZ',
    categoryCode: 'vehicle_up_to_3_5t',
    displayName: 'Vehicle up to 3.5 t',
    appliesToVehicleType: VehicleType.camper,
  ),
  VehicleType.vanUpTo35t: CountryVehicleCategory(
    countryCode: 'CZ',
    categoryCode: 'vehicle_up_to_3_5t',
    displayName: 'Vehicle up to 3.5 t',
    appliesToVehicleType: VehicleType.vanUpTo35t,
  ),
};

const Map<VehicleType, CountryVehicleCategory> _slovakiaMappings = {
  VehicleType.motorcycle: CountryVehicleCategory(
    countryCode: 'SK',
    categoryCode: 'exempt',
    displayName: 'Exempt (no vignette)',
    appliesToVehicleType: VehicleType.motorcycle,
    vignetteExempt: true,
  ),
  VehicleType.passengerCar: CountryVehicleCategory(
    countryCode: 'SK',
    categoryCode: 'vehicle',
    displayName: 'Vehicle',
    appliesToVehicleType: VehicleType.passengerCar,
  ),
  VehicleType.passengerCarWithTrailer: CountryVehicleCategory(
    countryCode: 'SK',
    categoryCode: 'vehicle_combination',
    displayName: 'Vehicle combination',
    appliesToVehicleType: VehicleType.passengerCarWithTrailer,
    ruleDescription:
        'Future logic may require an additional trailer vignette when the '
        'total combination weight exceeds 3.5 t.',
  ),
  VehicleType.camper: CountryVehicleCategory(
    countryCode: 'SK',
    categoryCode: 'vehicle',
    displayName: 'Vehicle',
    appliesToVehicleType: VehicleType.camper,
  ),
  VehicleType.vanUpTo35t: CountryVehicleCategory(
    countryCode: 'SK',
    categoryCode: 'vehicle',
    displayName: 'Vehicle',
    appliesToVehicleType: VehicleType.vanUpTo35t,
  ),
};

const Map<VehicleType, CountryVehicleCategory> _hungaryMappings = {
  VehicleType.motorcycle: CountryVehicleCategory(
    countryCode: 'HU',
    categoryCode: 'D1M',
    displayName: 'D1M (motorcycle)',
    appliesToVehicleType: VehicleType.motorcycle,
  ),
  VehicleType.passengerCar: CountryVehicleCategory(
    countryCode: 'HU',
    categoryCode: 'D1',
    displayName: 'D1 (passenger car)',
    appliesToVehicleType: VehicleType.passengerCar,
  ),
  VehicleType.passengerCarWithTrailer: CountryVehicleCategory(
    countryCode: 'HU',
    categoryCode: 'passenger_car_with_trailer',
    displayName: 'Passenger car with trailer',
    appliesToVehicleType: VehicleType.passengerCarWithTrailer,
    ruleDescription:
        'May map to D1 or D2 for the towing vehicle and category U for the '
        'trailer depending on registration, seats, and weight. Trailer '
        'category U may be required in future logic.',
  ),
  VehicleType.camper: CountryVehicleCategory(
    countryCode: 'HU',
    categoryCode: 'D2',
    displayName: 'D2 (larger vehicle)',
    appliesToVehicleType: VehicleType.camper,
  ),
  VehicleType.vanUpTo35t: CountryVehicleCategory(
    countryCode: 'HU',
    categoryCode: 'D2',
    displayName: 'D2 (larger vehicle)',
    appliesToVehicleType: VehicleType.vanUpTo35t,
  ),
};

const Map<VehicleType, CountryVehicleCategory> _austriaMappings = {
  VehicleType.motorcycle: CountryVehicleCategory(
    countryCode: 'AT',
    categoryCode: 'motorcycle',
    displayName: 'Motorcycle',
    appliesToVehicleType: VehicleType.motorcycle,
  ),
  VehicleType.passengerCar: CountryVehicleCategory(
    countryCode: 'AT',
    categoryCode: 'vehicle_up_to_3_5t',
    displayName: 'Vehicle up to 3.5 t',
    appliesToVehicleType: VehicleType.passengerCar,
  ),
  VehicleType.passengerCarWithTrailer: CountryVehicleCategory(
    countryCode: 'AT',
    categoryCode: 'vehicle_up_to_3_5t',
    displayName: 'Vehicle up to 3.5 t',
    appliesToVehicleType: VehicleType.passengerCarWithTrailer,
    ruleDescription:
        'Trailer does not require a separate Austrian motorway vignette.',
  ),
  VehicleType.camper: CountryVehicleCategory(
    countryCode: 'AT',
    categoryCode: 'vehicle_up_to_3_5t',
    displayName: 'Vehicle up to 3.5 t',
    appliesToVehicleType: VehicleType.camper,
  ),
  VehicleType.vanUpTo35t: CountryVehicleCategory(
    countryCode: 'AT',
    categoryCode: 'vehicle_up_to_3_5t',
    displayName: 'Vehicle up to 3.5 t',
    appliesToVehicleType: VehicleType.vanUpTo35t,
  ),
};

const Map<VehicleType, CountryVehicleCategory> _sloveniaMappings = {
  VehicleType.motorcycle: CountryVehicleCategory(
    countryCode: 'SI',
    categoryCode: 'class_1',
    displayName: 'Class 1',
    appliesToVehicleType: VehicleType.motorcycle,
  ),
  VehicleType.passengerCar: CountryVehicleCategory(
    countryCode: 'SI',
    categoryCode: 'class_2A',
    displayName: 'Class 2A',
    appliesToVehicleType: VehicleType.passengerCar,
  ),
  VehicleType.passengerCarWithTrailer: CountryVehicleCategory(
    countryCode: 'SI',
    categoryCode: 'class_2A',
    displayName: 'Class 2A',
    appliesToVehicleType: VehicleType.passengerCarWithTrailer,
    ruleDescription:
        'Default class 2A. Future logic should support class 2B when vehicle '
        'height above the front axle exceeds 1.3 m.',
  ),
  VehicleType.camper: CountryVehicleCategory(
    countryCode: 'SI',
    categoryCode: 'class_2A',
    displayName: 'Class 2A',
    appliesToVehicleType: VehicleType.camper,
    ruleDescription:
        'Campervans registered as campers are treated as class 2A regardless '
        'of height above the front axle.',
  ),
  VehicleType.vanUpTo35t: CountryVehicleCategory(
    countryCode: 'SI',
    categoryCode: 'class_2B',
    displayName: 'Class 2B',
    appliesToVehicleType: VehicleType.vanUpTo35t,
    ruleDescription:
        'Default class 2B for vans/light trucks when height above the front '
        'axle is over 1.3 m.',
  ),
};

const Map<VehicleType, CountryVehicleCategory> _croatiaMappings = {
  VehicleType.motorcycle: CountryVehicleCategory(
    countryCode: 'HR',
    categoryCode: 'IA',
    displayName: 'Category IA',
    appliesToVehicleType: VehicleType.motorcycle,
  ),
  VehicleType.passengerCar: CountryVehicleCategory(
    countryCode: 'HR',
    categoryCode: 'I',
    displayName: 'Category I',
    appliesToVehicleType: VehicleType.passengerCar,
  ),
  VehicleType.passengerCarWithTrailer: CountryVehicleCategory(
    countryCode: 'HR',
    categoryCode: 'II',
    displayName: 'Category II',
    appliesToVehicleType: VehicleType.passengerCarWithTrailer,
  ),
  VehicleType.camper: CountryVehicleCategory(
    countryCode: 'HR',
    categoryCode: 'II',
    displayName: 'Category II',
    appliesToVehicleType: VehicleType.camper,
  ),
  VehicleType.vanUpTo35t: CountryVehicleCategory(
    countryCode: 'HR',
    categoryCode: 'II',
    displayName: 'Category II',
    appliesToVehicleType: VehicleType.vanUpTo35t,
  ),
};

const Map<VehicleType, CountryVehicleCategory> _germanyMappings = {
  VehicleType.motorcycle: CountryVehicleCategory(
    countryCode: 'DE',
    categoryCode: 'exempt',
    displayName: 'No motorway vignette',
    appliesToVehicleType: VehicleType.motorcycle,
    ruleDescription:
        'No passenger-car motorway vignette for vehicles up to 3.5 t. '
        'Freight vehicles or combinations over 3.5 t may be subject to the '
        'German truck toll system in future (out of scope).',
    vignetteExempt: true,
  ),
  VehicleType.passengerCar: CountryVehicleCategory(
    countryCode: 'DE',
    categoryCode: 'exempt',
    displayName: 'No motorway vignette',
    appliesToVehicleType: VehicleType.passengerCar,
    ruleDescription:
        'No passenger-car motorway vignette for vehicles up to 3.5 t. '
        'Freight vehicles or combinations over 3.5 t may be subject to the '
        'German truck toll system in future (out of scope).',
    vignetteExempt: true,
  ),
  VehicleType.passengerCarWithTrailer: CountryVehicleCategory(
    countryCode: 'DE',
    categoryCode: 'exempt',
    displayName: 'No motorway vignette',
    appliesToVehicleType: VehicleType.passengerCarWithTrailer,
    ruleDescription:
        'No passenger-car motorway vignette for vehicles up to 3.5 t. '
        'Freight vehicles or combinations over 3.5 t may be subject to the '
        'German truck toll system in future (out of scope).',
    vignetteExempt: true,
  ),
  VehicleType.camper: CountryVehicleCategory(
    countryCode: 'DE',
    categoryCode: 'exempt',
    displayName: 'No motorway vignette',
    appliesToVehicleType: VehicleType.camper,
    ruleDescription:
        'No passenger-car motorway vignette for vehicles up to 3.5 t. '
        'Freight vehicles or combinations over 3.5 t may be subject to the '
        'German truck toll system in future (out of scope).',
    vignetteExempt: true,
  ),
  VehicleType.vanUpTo35t: CountryVehicleCategory(
    countryCode: 'DE',
    categoryCode: 'exempt',
    displayName: 'No motorway vignette',
    appliesToVehicleType: VehicleType.vanUpTo35t,
    ruleDescription:
        'No passenger-car motorway vignette for vehicles up to 3.5 t. '
        'Freight vehicles or combinations over 3.5 t may be subject to the '
        'German truck toll system in future (out of scope).',
    vignetteExempt: true,
  ),
};
