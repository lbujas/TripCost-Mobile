import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/data/sources/speed_limits_v2_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_speed_limit.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';
import 'package:travel_cost_planner_europe/domain/services/speed_limits_v2_validator.dart';
import 'package:travel_cost_planner_europe/domain/services/vehicle_category_mapping_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const loader = JsonAssetLoader();
  const source = SpeedLimitsV2LocalSource(loader);
  const validator = SpeedLimitsV2Validator(VehicleCategoryMappingService());

  group('VehicleCategorySpeedLimit', () {
    test('fromJson parses vehicleType and road fields', () {
      final limit = VehicleCategorySpeedLimit.fromJson({
        'countryCode': 'CZ',
        'vehicleType': 'passengerCar',
        'categoryCode': 'vehicle_up_to_3_5t',
        'city': 50,
        'outsideCity': 90,
        'expressway': 110,
        'motorway': 130,
      });

      expect(limit.countryCode, 'CZ');
      expect(limit.vehicleType, 'passengerCar');
      expect(limit.motorway, 130);
    });
  });

  group('speed_limits_v2.json', () {
    test('loads 40 rows for 8 countries x 5 vehicle types', () async {
      final limits = await source.getAll();

      expect(limits, hasLength(40));
      expect(
        limits.map((limit) => limit.countryCode).toSet(),
        SpeedLimitsV2Validator.activeCountryCodes.toSet(),
      );
      expect(
        limits.map((limit) => limit.vehicleType).toSet(),
        VehicleType.selectableValues.map((type) => type.storageValue).toSet(),
      );
    });

    test('has full coverage for all active countries and vehicle types',
        () async {
      final limits = await source.getAll();
      final report = validator.validateCoverage(limits);

      expect(report.hasFullCoverage, isTrue);
      expect(report.missing, isEmpty);
      expect(report.categoryMismatches, isEmpty);
      expect(report.present, hasLength(40));
    });

    test('passengerCar limits match current ResultScreen hardcoded values',
        () async {
      const expected = {
        'PL': [50, 90, 120, 140],
        'CZ': [50, 90, 110, 130],
        'SK': [50, 90, 90, 130],
        'HU': [50, 90, 110, 130],
        'AT': [50, 100, 100, 130],
        'SI': [50, 90, 110, 130],
        'HR': [50, 90, 110, 130],
      };

      for (final entry in expected.entries) {
        final limit = await source.getForCountryAndVehicleType(
          countryCode: entry.key,
          vehicleType: VehicleType.passengerCar,
        );

        expect(limit, isNotNull);
        expect(limit!.city, entry.value[0]);
        expect(limit.outsideCity, entry.value[1]);
        expect(limit.expressway, entry.value[2]);
        expect(limit.motorway, entry.value[3]);
      }
    });

    test('getForCountryAndVehicleType returns motorcycle HR limits', () async {
      final limit = await source.getForCountryAndVehicleType(
        countryCode: 'HR',
        vehicleType: VehicleType.motorcycle,
      );

      expect(limit, isNotNull);
      expect(limit!.categoryCode, 'IA');
      expect(limit.vehicleType, 'motorcycle');
    });

    test('passengerCarWithTrailer differs from passengerCar for PL, HR, DE',
        () async {
      for (final countryCode in ['PL', 'HR', 'DE']) {
        final car = await source.getForCountryAndVehicleType(
          countryCode: countryCode,
          vehicleType: VehicleType.passengerCar,
        );
        final trailer = await source.getForCountryAndVehicleType(
          countryCode: countryCode,
          vehicleType: VehicleType.passengerCarWithTrailer,
        );

        expect(car, isNotNull);
        expect(trailer, isNotNull);
        expect(trailer!.outsideCity, isNot(car!.outsideCity));
      }
    });

    test('camper and van limits differ from passengerCar where configured',
        () async {
      final hrCamper = await source.getForCountryAndVehicleType(
        countryCode: 'HR',
        vehicleType: VehicleType.camper,
      );
      final hrCar = await source.getForCountryAndVehicleType(
        countryCode: 'HR',
        vehicleType: VehicleType.passengerCar,
      );
      expect(hrCamper!.outsideCity, isNot(hrCar!.outsideCity));

      final huVan = await source.getForCountryAndVehicleType(
        countryCode: 'HU',
        vehicleType: VehicleType.vanUpTo35t,
      );
      final huCar = await source.getForCountryAndVehicleType(
        countryCode: 'HU',
        vehicleType: VehicleType.passengerCar,
      );
      expect(huVan!.motorway, isNot(huCar!.motorway));

      final plCamper = await source.getForCountryAndVehicleType(
        countryCode: 'PL',
        vehicleType: VehicleType.camper,
      );
      final plCar = await source.getForCountryAndVehicleType(
        countryCode: 'PL',
        vehicleType: VehicleType.passengerCar,
      );
      expect(plCamper!.motorway, plCar!.motorway);
    });
  });
}
