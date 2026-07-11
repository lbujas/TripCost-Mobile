import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';
import 'package:travel_cost_planner_europe/domain/services/vehicle_category_mapping_service.dart';

void main() {
  const service = VehicleCategoryMappingService();

  group('VehicleCategoryMappingService', () {
    test('supports all required route countries', () {
      expect(
        VehicleCategoryMappingService.supportedCountryCodes,
        containsAll(['PL', 'CZ', 'SK', 'HU', 'AT', 'SI', 'HR', 'DE']),
      );
    });

    test('PL maps all vehicle types to vignette exempt', () {
      for (final vehicleType in VehicleType.selectableValues) {
        final category = service.getCategoryFor(
          countryCode: 'PL',
          vehicleType: vehicleType,
        );

        expect(category.vignetteExempt, isTrue);
        expect(category.categoryCode, 'exempt');
      }
    });

    test('CZ maps passenger car to vehicle_up_to_3_5t', () {
      final category = service.getCategoryFor(
        countryCode: 'cz',
        vehicleType: VehicleType.passengerCar,
      );

      expect(category.countryCode, 'CZ');
      expect(category.categoryCode, 'vehicle_up_to_3_5t');
      expect(category.vignetteExempt, isFalse);
    });

    test('CZ maps motorcycle to exempt', () {
      final category = service.getCategoryFor(
        countryCode: 'CZ',
        vehicleType: VehicleType.motorcycle,
      );

      expect(category.categoryCode, 'exempt');
      expect(category.vignetteExempt, isTrue);
    });

    test('SK trailer combination includes future weight note', () {
      final category = service.getCategoryFor(
        countryCode: 'SK',
        vehicleType: VehicleType.passengerCarWithTrailer,
      );

      expect(category.categoryCode, 'vehicle_combination');
      expect(category.ruleDescription, isNotNull);
      expect(category.ruleDescription, contains('3.5 t'));
    });

    test('HU maps motorcycle to D1M', () {
      final category = service.getCategoryFor(
        countryCode: 'HU',
        vehicleType: VehicleType.motorcycle,
      );

      expect(category.categoryCode, 'D1M');
    });

    test('HU maps passenger car with trailer to composite category', () {
      final category = service.getCategoryFor(
        countryCode: 'HU',
        vehicleType: VehicleType.passengerCarWithTrailer,
      );

      expect(category.categoryCode, 'passenger_car_with_trailer');
      expect(category.ruleDescription, contains('category U'));
    });

    test('SI maps camper to class_2A with camper note', () {
      final category = service.getCategoryFor(
        countryCode: 'SI',
        vehicleType: VehicleType.camper,
      );

      expect(category.categoryCode, 'class_2A');
      expect(category.ruleDescription, contains('campers'));
    });

    test('SI maps van to class_2B by default', () {
      final category = service.getCategoryFor(
        countryCode: 'SI',
        vehicleType: VehicleType.vanUpTo35t,
      );

      expect(category.categoryCode, 'class_2B');
    });

    test('HR maps passenger car to category I', () {
      final category = service.getCategoryFor(
        countryCode: 'HR',
        vehicleType: VehicleType.passengerCar,
      );

      expect(category.categoryCode, 'I');
    });

    test('DE maps all types to exempt with truck toll note', () {
      final category = service.getCategoryFor(
        countryCode: 'DE',
        vehicleType: VehicleType.vanUpTo35t,
      );

      expect(category.vignetteExempt, isTrue);
      expect(category.ruleDescription, contains('truck toll'));
    });

    test('HU trailer billing uses D1 and U vignette categories', () {
      expect(
        service.vignetteBillingCategoryCodes(
          countryCode: 'HU',
          vehicleType: VehicleType.passengerCarWithTrailer,
        ),
        ['D1', 'U'],
      );
    });

    test('CZ motorcycle is vignette exempt', () {
      expect(
        service.vignetteBillingCategoryCodes(
          countryCode: 'CZ',
          vehicleType: VehicleType.motorcycle,
        ),
        isEmpty,
      );
    });

    test('categoriesForCountry returns one entry per vehicle type', () {
      final categories = service.categoriesForCountry('AT');

      expect(categories, hasLength(VehicleType.selectableValues.length));
      expect(
        categories.map((category) => category.appliesToVehicleType).toSet(),
        VehicleType.selectableValues.toSet(),
      );
    });

    test('throws for unsupported country', () {
      expect(
        () => service.getCategoryFor(
          countryCode: 'FR',
          vehicleType: VehicleType.passengerCar,
        ),
        throwsArgumentError,
      );
    });
  });
}
