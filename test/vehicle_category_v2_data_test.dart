import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/data/sources/speed_limits_v2_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/toll_prices_v2_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/vignette_prices_v2_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_speed_limit.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_toll_price.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_vignette_price.dart';
import 'package:travel_cost_planner_europe/domain/services/vehicle_category_mapping_service.dart';
import 'package:travel_cost_planner_europe/domain/services/vehicle_category_v2_data_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const loader = JsonAssetLoader();
  const mappingService = VehicleCategoryMappingService();
  const validator = VehicleCategoryV2DataValidator(mappingService);

  const vignetteSource = VignettePricesV2LocalSource(loader);
  const tollSource = TollPricesV2LocalSource(loader);
  const speedLimitSource = SpeedLimitsV2LocalSource(loader);

  group('VehicleCategoryVignettePrice', () {
    test('fromJson parses required fields', () {
      final price = VehicleCategoryVignettePrice.fromJson({
        'countryCode': 'cz',
        'categoryCode': 'vehicle_up_to_3_5t',
        'name': 'Sample vignette',
        'validityDays': 10,
        'price': 12.5,
        'currency': 'EUR',
        'notes': 'optional',
      });

      expect(price.countryCode, 'CZ');
      expect(price.categoryCode, 'vehicle_up_to_3_5t');
      expect(price.name, 'Sample vignette');
      expect(price.validityDays, 10);
      expect(price.price, 12.5);
      expect(price.currency, 'EUR');
      expect(price.notes, 'optional');
    });
  });

  group('VehicleCategoryTollPrice', () {
    test('fromJson parses required fields with routeId', () {
      final price = VehicleCategoryTollPrice.fromJson({
        'countryCode': 'HR',
        'categoryCode': 'I',
        'routeId': 'pl_hr_sk_hu',
        'name': 'Sample toll',
        'amount': 5.0,
        'currency': 'EUR',
      });

      expect(price.routeId, 'pl_hr_sk_hu');
      expect(price.tollId, isNull);
      expect(price.amount, 5.0);
    });

    test('fromJson requires routeId or tollId', () {
      expect(
        () => VehicleCategoryTollPrice.fromJson({
          'countryCode': 'HR',
          'categoryCode': 'I',
          'name': 'Invalid toll',
          'amount': 5.0,
          'currency': 'EUR',
        }),
        throwsFormatException,
      );
    });
  });

  group('VehicleCategorySpeedLimit', () {
    test('fromJson parses required fields', () {
      final limit = VehicleCategorySpeedLimit.fromJson({
        'countryCode': 'SI',
        'vehicleType': 'passengerCar',
        'categoryCode': 'class_2A',
        'city': 50,
        'outsideCity': 90,
        'expressway': 110,
        'motorway': 130,
      });

      expect(limit.countryCode, 'SI');
      expect(limit.motorway, 130);
    });
  });

  group('v2 JSON assets', () {
    test('vignette_prices_v2.json loads and category codes are known', () async {
      final prices = await vignetteSource.getAll();

      expect(prices, isNotEmpty);
      for (final price in prices) {
        expect(price.countryCode, isNotEmpty);
        expect(price.categoryCode, isNotEmpty);
        expect(price.validityDays, greaterThan(0));
      }

      // SK trailer is a future optional category not yet in VehicleCategoryMappingService.
      final mappedPrices = prices
          .where(
            (price) =>
                !(price.countryCode == 'SK' && price.categoryCode == 'trailer'),
          )
          .toList();
      expect(validator.validateVignettePrices(mappedPrices), isEmpty);
    });

    test('vignette_prices_v2.json has no PL, DE, or HR entries', () async {
      final prices = await vignetteSource.getAll();
      final excludedCountries = prices
          .where((price) => {'PL', 'DE', 'HR'}.contains(price.countryCode))
          .toList();

      expect(excludedCountries, isEmpty);
    });

    test('vignette_prices_v2.json CZ prices use CZK', () async {
      final prices = await vignetteSource.getForCountryAndCategory(
        countryCode: 'CZ',
        categoryCode: 'vehicle_up_to_3_5t',
      );

      expect(prices, hasLength(4));
      expect(prices.every((price) => price.currency == 'CZK'), isTrue);
      expect(
        prices.firstWhere((price) => price.validityDays == 10).price,
        300,
      );
    });

    test('vignette_prices_v2.json HU prices use HUF categories', () async {
      final d1 = await vignetteSource.getForCountryAndCategory(
        countryCode: 'HU',
        categoryCode: 'D1',
      );
      final trailerU = await vignetteSource.getForCountryAndCategory(
        countryCode: 'HU',
        categoryCode: 'U',
      );

      expect(d1, hasLength(3));
      expect(d1.every((price) => price.currency == 'HUF'), isTrue);
      expect(
        d1.firstWhere((price) => price.validityDays == 10).price,
        6900,
      );
      expect(trailerU.firstWhere((price) => price.validityDays == 10).price,
          6900);
      final mappedPrices = (await vignetteSource.getAll())
          .where(
            (price) =>
                !(price.countryCode == 'SK' && price.categoryCode == 'trailer'),
          )
          .toList();
      expect(validator.validateVignettePrices(mappedPrices), isEmpty);
    });

    test('toll_prices_v2.json loads and category codes are known', () async {
      final prices = await tollSource.getAll();

      expect(prices, isNotEmpty);
      for (final price in prices) {
        expect(price.countryCode, isNotEmpty);
        expect(price.categoryCode, isNotEmpty);
        expect(price.routeId != null || price.tollId != null, isTrue);
      }

      expect(validator.validateTollPrices(prices), isEmpty);
    });

    test('speed_limits_v2.json loads and category codes are known', () async {
      final limits = await speedLimitSource.getAll();

      expect(limits, hasLength(40));
      for (final limit in limits) {
        expect(limit.city, greaterThan(0));
        expect(limit.motorway, greaterThan(0));
        expect(limit.vehicleType, isNotEmpty);
      }

      expect(validator.validateSpeedLimits(limits), isEmpty);
    });

    test('getForCountryAndCategory returns matching vignette rows', () async {
      final prices = await vignetteSource.getForCountryAndCategory(
        countryCode: 'SK',
        categoryCode: 'vehicle',
      );

      expect(prices, hasLength(4));
      expect(prices.first.name, contains('Slovakia'));
    });
  });
}
