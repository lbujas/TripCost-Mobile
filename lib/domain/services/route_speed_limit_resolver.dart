import 'package:travel_cost_planner_europe/domain/models/vehicle_category_speed_limit.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';

enum RouteSpeedLimitSource {
  v2,
  fallback,
}

class RouteSpeedLimitValues {
  const RouteSpeedLimitValues({
    required this.countryCode,
    required this.city,
    required this.outsideCity,
    required this.expressway,
    required this.motorway,
  });

  final String countryCode;
  final int? city;
  final int? outsideCity;
  final int? expressway;
  final int? motorway;
}

class RouteSpeedLimitResolution {
  const RouteSpeedLimitResolution({
    required this.values,
    required this.source,
  });

  final RouteSpeedLimitValues values;
  final RouteSpeedLimitSource source;
}

/// Resolves route speed limits from v2 data with ResultScreen legacy fallback.
class RouteSpeedLimitResolver {
  const RouteSpeedLimitResolver();

  /// Legacy country-only limits previously hardcoded in ResultScreen.
  static const Map<String, RouteSpeedLimitValues> resultScreenFallbackByCountry = {
    'PL': RouteSpeedLimitValues(
      countryCode: 'PL',
      city: 50,
      outsideCity: 90,
      expressway: 120,
      motorway: 140,
    ),
    'CZ': RouteSpeedLimitValues(
      countryCode: 'CZ',
      city: 50,
      outsideCity: 90,
      expressway: 110,
      motorway: 130,
    ),
    'SK': RouteSpeedLimitValues(
      countryCode: 'SK',
      city: 50,
      outsideCity: 90,
      expressway: 90,
      motorway: 130,
    ),
    'HU': RouteSpeedLimitValues(
      countryCode: 'HU',
      city: 50,
      outsideCity: 90,
      expressway: 110,
      motorway: 130,
    ),
    'AT': RouteSpeedLimitValues(
      countryCode: 'AT',
      city: 50,
      outsideCity: 100,
      expressway: 100,
      motorway: 130,
    ),
    'SI': RouteSpeedLimitValues(
      countryCode: 'SI',
      city: 50,
      outsideCity: 90,
      expressway: 110,
      motorway: 130,
    ),
    'HR': RouteSpeedLimitValues(
      countryCode: 'HR',
      city: 50,
      outsideCity: 90,
      expressway: 110,
      motorway: 130,
    ),
  };

  List<RouteSpeedLimitResolution> resolveForRoute({
    required List<String> routeCountryCodes,
    required VehicleType vehicleType,
    List<VehicleCategorySpeedLimit>? v2Limits,
    Map<String, RouteSpeedLimitValues> fallbackByCountry =
        resultScreenFallbackByCountry,
  }) {
    final v2Index = <String, VehicleCategorySpeedLimit>{};
    if (v2Limits != null) {
      for (final limit in v2Limits) {
        v2Index[_v2Key(limit.countryCode, limit.vehicleType)] = limit;
      }
    }

    final results = <RouteSpeedLimitResolution>[];
    for (final countryCode in routeCountryCodes) {
      final normalized = countryCode.toUpperCase();
      final v2 = v2Index[_v2Key(normalized, vehicleType.storageValue)];
      final resolution = resolveForCountry(
        countryCode: normalized,
        vehicleType: vehicleType,
        v2Limit: v2,
        fallbackByCountry: fallbackByCountry,
      );
      if (resolution != null) {
        results.add(resolution);
      }
    }
    return results;
  }

  RouteSpeedLimitResolution? resolveForCountry({
    required String countryCode,
    required VehicleType vehicleType,
    VehicleCategorySpeedLimit? v2Limit,
    Map<String, RouteSpeedLimitValues> fallbackByCountry =
        resultScreenFallbackByCountry,
  }) {
    final normalized = countryCode.toUpperCase();

    if (v2Limit != null) {
      return RouteSpeedLimitResolution(
        source: RouteSpeedLimitSource.v2,
        values: RouteSpeedLimitValues(
          countryCode: normalized,
          city: v2Limit.city,
          outsideCity: v2Limit.outsideCity,
          expressway: v2Limit.expressway,
          motorway: v2Limit.motorway,
        ),
      );
    }

    final fallback = fallbackByCountry[normalized];
    if (fallback != null) {
      return RouteSpeedLimitResolution(
        source: RouteSpeedLimitSource.fallback,
        values: fallback,
      );
    }

    return null;
  }

  static String _v2Key(String countryCode, String vehicleType) {
    return '${countryCode.toUpperCase()}|$vehicleType';
  }
}
