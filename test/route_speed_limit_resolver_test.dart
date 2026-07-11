import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/data/sources/speed_limits_v2_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_speed_limit.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';
import 'package:travel_cost_planner_europe/domain/services/route_speed_limit_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const resolver = RouteSpeedLimitResolver();
  const loader = JsonAssetLoader();
  const source = SpeedLimitsV2LocalSource(loader);

  VehicleCategorySpeedLimit v2Limit({
    required String countryCode,
    required VehicleType vehicleType,
    int city = 40,
    int outsideCity = 80,
    int expressway = 100,
    int motorway = 120,
  }) {
    return VehicleCategorySpeedLimit(
      countryCode: countryCode,
      vehicleType: vehicleType.storageValue,
      categoryCode: 'test',
      city: city,
      outsideCity: outsideCity,
      expressway: expressway,
      motorway: motorway,
    );
  }

  group('RouteSpeedLimitResolver', () {
    test('passengerCar v2 limits match legacy ResultScreen fallback values',
        () async {
      final v2Limits = await source.getAll();

      for (final entry
          in RouteSpeedLimitResolver.resultScreenFallbackByCountry.entries) {
        final resolution = resolver.resolveForCountry(
          countryCode: entry.key,
          vehicleType: VehicleType.passengerCar,
          v2Limit: v2Limits.firstWhere(
            (limit) =>
                limit.countryCode == entry.key &&
                limit.vehicleType == VehicleType.passengerCar.storageValue,
          ),
        );

        expect(resolution, isNotNull);
        expect(resolution!.source, RouteSpeedLimitSource.v2);
        expect(resolution.values.city, entry.value.city);
        expect(resolution.values.outsideCity, entry.value.outsideCity);
        expect(resolution.values.expressway, entry.value.expressway);
        expect(resolution.values.motorway, entry.value.motorway);
      }
    });

    test('uses selected vehicleType when loading v2 speed limits', () {
      final resolutions = resolver.resolveForRoute(
        routeCountryCodes: const ['HR'],
        vehicleType: VehicleType.motorcycle,
        v2Limits: [
          v2Limit(
            countryCode: 'HR',
            vehicleType: VehicleType.motorcycle,
            city: 45,
            outsideCity: 85,
            expressway: 105,
            motorway: 125,
          ),
          v2Limit(
            countryCode: 'HR',
            vehicleType: VehicleType.passengerCar,
            city: 50,
            outsideCity: 90,
            expressway: 110,
            motorway: 130,
          ),
        ],
      );

      expect(resolutions, hasLength(1));
      expect(resolutions.single.source, RouteSpeedLimitSource.v2);
      expect(resolutions.single.values.city, 45);
      expect(resolutions.single.values.motorway, 125);
    });

    test('falls back to legacy map when v2 row is missing', () {
      final resolution = resolver.resolveForCountry(
        countryCode: 'PL',
        vehicleType: VehicleType.passengerCar,
        v2Limit: null,
      );

      expect(resolution, isNotNull);
      expect(resolution!.source, RouteSpeedLimitSource.fallback);
      expect(
        resolution.values,
        RouteSpeedLimitResolver.resultScreenFallbackByCountry['PL'],
      );
    });

    test('falls back when v2 list is unavailable for route country', () {
      final resolutions = resolver.resolveForRoute(
        routeCountryCodes: const ['PL', 'CZ'],
        vehicleType: VehicleType.passengerCar,
        v2Limits: null,
      );

      expect(resolutions, hasLength(2));
      expect(resolutions.every((r) => r.source == RouteSpeedLimitSource.fallback),
          isTrue);
    });

    test('returns null when neither v2 nor fallback exists', () {
      final resolution = resolver.resolveForCountry(
        countryCode: 'DE',
        vehicleType: VehicleType.passengerCar,
        v2Limit: null,
      );

      expect(resolution, isNull);
    });

    test('v2 covers DE even though legacy fallback has no DE entry', () async {
      final limit = await source.getForCountryAndVehicleType(
        countryCode: 'DE',
        vehicleType: VehicleType.passengerCar,
      );

      final resolution = resolver.resolveForCountry(
        countryCode: 'DE',
        vehicleType: VehicleType.passengerCar,
        v2Limit: limit,
      );

      expect(resolution, isNotNull);
      expect(resolution!.source, RouteSpeedLimitSource.v2);
      expect(resolution.values.motorway, 130);
    });

    test('trailer v2 limits differ from passengerCar for PL and HR', () async {
      final v2Limits = await source.getAll();

      for (final countryCode in ['PL', 'HR']) {
        final car = v2Limits.firstWhere(
          (limit) =>
              limit.countryCode == countryCode &&
              limit.vehicleType == VehicleType.passengerCar.storageValue,
        );
        final trailer = v2Limits.firstWhere(
          (limit) =>
              limit.countryCode == countryCode &&
              limit.vehicleType ==
                  VehicleType.passengerCarWithTrailer.storageValue,
        );

        final carResolution = resolver.resolveForCountry(
          countryCode: countryCode,
          vehicleType: VehicleType.passengerCar,
          v2Limit: car,
        );
        final trailerResolution = resolver.resolveForCountry(
          countryCode: countryCode,
          vehicleType: VehicleType.passengerCarWithTrailer,
          v2Limit: trailer,
        );

        expect(carResolution!.values.motorway, isNot(trailerResolution!.values.motorway));
      }
    });
  });
}
