import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_toll_segments_v2_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/vignette_prices_v2_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_destination.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_entry_adjustment.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_lucko_exit_toll.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_region.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll_matrix_entry.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll_segment_v2.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';
import 'package:travel_cost_planner_europe/domain/models/route_option.dart';
import 'package:travel_cost_planner_europe/domain/models/toll.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_direction.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_vignette_price.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';
import 'package:travel_cost_planner_europe/domain/models/vignette.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_destination_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_entry_adjustment_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_lucko_exit_toll_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_toll_matrix_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/toll_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/vignette_repository.dart';
import 'package:travel_cost_planner_europe/domain/services/cost_calculation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CostCalculationService service;
  late CostCalculationService legacyFallbackService;
  late _MockCroatiaEntryAdjustmentRepository entryAdjustmentRepository;
  late _MockCroatiaLuckoExitTollRepository luckoExitTollRepository;

  const route = RouteOption(
    id: 'pl_hr_sk_hu',
    origin: 'Poland',
    destination: 'Croatia',
    distanceKm: 1125,
    durationMinutes: 1440,
    countryCodes: ['PL', 'SK', 'HU', 'HR'],
    croatiaEntryGateId: 'gorican',
  );

  const car = Car(
    id: 'test-car',
    name: 'Test Car',
    fuelConsumptionLitersPer100Km: 8.5,
    fuelType: 'PB95',
  );

  const splitDestination = CroatiaDestination(
    id: 'split',
    name: 'Split',
    regionId: 'split',
    extraDistanceKm: 0,
    popular: true,
    croatiaExitGateId: 'dugopolje',
  );

  const makarskaDestination = CroatiaDestination(
    id: 'omis',
    name: 'Omiš',
    regionId: 'makarska',
    extraDistanceKm: 0,
    popular: false,
    croatiaExitGateId: 'sestanovac',
  );

  const eurToPln = 4.30;
  const currencyRates = CurrencyRates(
    baseCurrency: 'EUR',
    updatedAt: '2026-06-10',
    rates: {
      'EUR': 1.0,
      'PLN': eurToPln,
      'CZK': 24.24,
      'HUF': 354.80,
    },
  );

  double hufToPln(double amount) => amount / 354.80 * eurToPln;

  setUp(() {
    entryAdjustmentRepository = _MockCroatiaEntryAdjustmentRepository();
    luckoExitTollRepository = _MockCroatiaLuckoExitTollRepository();
    final v2Reader = CroatiaTollSegmentsV2LocalSource(const JsonAssetLoader());
    final vignetteV2Source = VignettePricesV2LocalSource(const JsonAssetLoader());

    service = CostCalculationService(
      vignetteRepository: _MockVignetteRepository(),
      vignettePricesV2LocalSource: vignetteV2Source,
      tollRepository: _MockTollRepository(),
      croatiaDestinationRepository: _MockCroatiaDestinationRepository(),
      croatiaEntryAdjustmentRepository: entryAdjustmentRepository,
      croatiaLuckoExitTollRepository: luckoExitTollRepository,
      croatiaTollMatrixRepository: _MockCroatiaTollMatrixRepository(),
      croatiaTollSegmentsV2Reader: v2Reader,
    );

    legacyFallbackService = CostCalculationService(
      vignetteRepository: _MockVignetteRepository(),
      vignettePricesV2LocalSource: const _EmptyVignettePricesV2LocalSource(),
      tollRepository: _MockTollRepository(),
      croatiaDestinationRepository: _MockCroatiaDestinationRepository(),
      croatiaEntryAdjustmentRepository: entryAdjustmentRepository,
      croatiaLuckoExitTollRepository: luckoExitTollRepository,
      croatiaTollMatrixRepository: _MockCroatiaTollMatrixRepository(),
      croatiaTollSegmentsV2Reader: const _EmptyCroatiaTollSegmentsV2Reader(),
    );
  });

  test('calculates fuel cost and splits total per person', () async {
    final result = await service.calculateTripCost(
      route: route,
      car: car,
      tripDays: 16,
      peopleCount: 3,
      fuelPricePln: 6.00,
      eurToPln: eurToPln,
      tripDirection: TripDirection.roundTrip,
      extraDistanceKm: 0,
    );

    expect(result.oneWayDistanceKm, 1125);
    expect(result.totalDistanceKm, 2250);
    expect(result.fuelLiters, closeTo(191.25, 0.001));
    expect(result.fuelCostPln, closeTo(1147.50, 0.001));
    expect(result.totalCostPln, greaterThan(result.fuelCostPln));
    expect(result.costPerPersonPln, closeTo(result.totalCostPln / 3, 0.001));
    expect(result.selectedVignettes, isNotEmpty);
    expect(result.selectedTolls, hasLength(1));
    expect(result.tollMultiplier, 2);
    expect(result.oneWayTollCostPln, closeTo(55 * eurToPln, 0.001));
    expect(result.totalTollCostPln, closeTo(110 * eurToPln, 0.001));
    expect(result.tollCostPln, closeTo(110 * eurToPln, 0.001));
  });

  test('round trip doubles tolls but not vignettes for same tripDays', () async {
    const expectedOneWayTollEur = 30.40;

    final oneWayResult = await service.calculateTripCost(
      route: route,
      car: car,
      tripDays: 16,
      peopleCount: 2,
      fuelPricePln: 6.00,
      eurToPln: eurToPln,
      tripDirection: TripDirection.oneWay,
      extraDistanceKm: 0,
      croatiaDestination: splitDestination,
    );

    final roundTripResult = await service.calculateTripCost(
      route: route,
      car: car,
      tripDays: 16,
      peopleCount: 2,
      fuelPricePln: 6.00,
      eurToPln: eurToPln,
      tripDirection: TripDirection.roundTrip,
      extraDistanceKm: 0,
      croatiaDestination: splitDestination,
    );

    final expectedOneWayTollPln = expectedOneWayTollEur * eurToPln;

    expect(oneWayResult.tollMultiplier, 1);
    expect(oneWayResult.oneWayTollCostPln, closeTo(expectedOneWayTollPln, 0.001));
    expect(oneWayResult.totalTollCostPln, closeTo(expectedOneWayTollPln, 0.001));

    expect(roundTripResult.tollMultiplier, 2);
    expect(
      roundTripResult.oneWayTollCostPln,
      closeTo(expectedOneWayTollPln, 0.001),
    );
    expect(
      roundTripResult.totalTollCostPln,
      closeTo(expectedOneWayTollPln * 2, 0.001),
    );
    expect(
      roundTripResult.vignetteCostPln,
      closeTo(oneWayResult.vignetteCostPln, 0.001),
    );
  });

  test('v2 Lučko toll: gorican entry + dugopolje exit = 30.40 EUR for car I',
      () async {
    final result = await service.calculateTripCost(
      route: route,
      car: car,
      tripDays: 7,
      peopleCount: 2,
      fuelPricePln: 6.00,
      eurToPln: eurToPln,
      tripDirection: TripDirection.oneWay,
      extraDistanceKm: 0,
      croatiaDestination: splitDestination,
    );

    expect(result.selectedTolls, hasLength(1));
    expect(result.selectedTolls.first.amount, closeTo(30.40, 0.001));
    expect(result.selectedTolls.first.id, 'hr_v2_gorican_dugopolje_I');
    expect(result.croatiaEntryGateId, 'gorican');
    expect(result.croatiaExitGateId, 'dugopolje');
    expect(result.croatiaTollAccuracy, 'verified');
    expect(result.croatiaTollFallbackUsed, isFalse);
  });

  test('falls back to legacy Lučko data when v2 segments are unavailable',
      () async {
    _setupLuckoGoricanDugopolje(
      entryAdjustmentRepository,
      luckoExitTollRepository,
    );

    final result = await legacyFallbackService.calculateTripCost(
      route: route,
      car: car,
      tripDays: 7,
      peopleCount: 2,
      fuelPricePln: 6.00,
      eurToPln: eurToPln,
      tripDirection: TripDirection.oneWay,
      extraDistanceKm: 0,
      croatiaDestination: splitDestination,
    );

    expect(result.selectedTolls.first.amount, closeTo(29.80, 0.001));
    expect(result.selectedTolls.first.id, 'hr_lucko_gorican_dugopolje');
    expect(result.croatiaTollFallbackUsed, isFalse);
  });

  test('v2 Lučko toll: trakoscan entry + sestanovac exit = 35.40 EUR for car I',
      () async {
    const trakoscanRoute = RouteOption(
      id: 'pl_hr_cz_at_si',
      origin: 'Poland',
      destination: 'Croatia',
      distanceKm: 1100,
      durationMinutes: 1380,
      countryCodes: ['PL', 'CZ', 'AT', 'SI', 'HR'],
      croatiaEntryGateId: 'trakoscan',
    );

    final result = await service.calculateTripCost(
      route: trakoscanRoute,
      car: car,
      tripDays: 7,
      peopleCount: 2,
      fuelPricePln: 6.00,
      eurToPln: eurToPln,
      tripDirection: TripDirection.oneWay,
      extraDistanceKm: 0,
      croatiaDestination: makarskaDestination,
    );

    expect(result.selectedTolls.first.amount, closeTo(35.40, 0.001));
    expect(result.croatiaEntryGateId, 'trakoscan');
    expect(result.croatiaExitGateId, 'sestanovac');
    expect(result.croatiaTollFallbackUsed, isFalse);
  });

  group('Croatia toll v2 vehicle categories', () {
    Future<double> croatiaTollAmount({
      required Car testCar,
      required CroatiaDestination destination,
    }) async {
      final result = await service.calculateTripCost(
        route: route,
        car: testCar,
        tripDays: 7,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
        croatiaDestination: destination,
      );

      return result.selectedTolls.first.amount;
    }

    test('gorican -> dugopolje varies by vehicle type', () async {
      final motorcycleAmount = await croatiaTollAmount(
        testCar: car.copyWithVehicleType(VehicleType.motorcycle),
        destination: splitDestination,
      );
      final passengerAmount = await croatiaTollAmount(
        testCar: car,
        destination: splitDestination,
      );
      final trailerAmount = await croatiaTollAmount(
        testCar: car.copyWithVehicleType(VehicleType.passengerCarWithTrailer),
        destination: splitDestination,
      );
      final camperAmount = await croatiaTollAmount(
        testCar: car.copyWithVehicleType(VehicleType.camper),
        destination: splitDestination,
      );
      final vanAmount = await croatiaTollAmount(
        testCar: car.copyWithVehicleType(VehicleType.vanUpTo35t),
        destination: splitDestination,
      );

      expect(motorcycleAmount, closeTo(19.50, 0.001));
      expect(passengerAmount, closeTo(30.40, 0.001));
      expect(trailerAmount, closeTo(50.90, 0.001));
      expect(camperAmount, closeTo(50.90, 0.001));
      expect(vanAmount, closeTo(50.90, 0.001));
      expect(motorcycleAmount, lessThan(passengerAmount));
      expect(passengerAmount, lessThan(trailerAmount));
    });

    test('gorican -> sestanovac varies by vehicle type', () async {
      final motorcycleAmount = await croatiaTollAmount(
        testCar: car.copyWithVehicleType(VehicleType.motorcycle),
        destination: makarskaDestination,
      );
      final passengerAmount = await croatiaTollAmount(
        testCar: car,
        destination: makarskaDestination,
      );
      final camperAmount = await croatiaTollAmount(
        testCar: car.copyWithVehicleType(VehicleType.camper),
        destination: makarskaDestination,
      );

      expect(motorcycleAmount, closeTo(21.20, 0.001));
      expect(passengerAmount, closeTo(35.40, 0.001));
      expect(camperAmount, closeTo(54.70, 0.001));
      expect(motorcycleAmount, lessThan(passengerAmount));
      expect(passengerAmount, lessThan(camperAmount));
    });
  });

  group('vignette v2 vehicle categories', () {
    Future<double> vignetteCostFor({
      required Car testCar,
      int tripDays = 10,
    }) async {
      final result = await service.calculateTripCost(
        route: route,
        car: testCar,
        tripDays: tripDays,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: currencyRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
      );

      return result.vignetteCostPln;
    }

    test('motorcycle has no SK vignette and uses HU D1M', () async {
      final result = await service.calculateTripCost(
        route: route,
        car: car.copyWithVehicleType(VehicleType.motorcycle),
        tripDays: 10,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: currencyRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
      );

      expect(
        result.selectedVignettes.where((v) => v.countryCode == 'SK'),
        isEmpty,
      );
      expect(
        result.selectedVignettes.singleWhere((v) => v.countryCode == 'HU').unitPrice,
        3450,
      );
      expect(result.vignetteCostPln, closeTo(hufToPln(3450), 0.01));
    });

    test('passengerCar uses SK vehicle and HU D1 categories', () async {
      final result = await service.calculateTripCost(
        route: route,
        car: car,
        tripDays: 10,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: currencyRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
      );

      final skVignette =
          result.selectedVignettes.singleWhere((v) => v.countryCode == 'SK');
      final huVignette =
          result.selectedVignettes.singleWhere((v) => v.countryCode == 'HU');

      expect(skVignette.validDays, 10);
      expect(skVignette.unitPrice, 10.8);
      expect(huVignette.validDays, 10);
      expect(huVignette.unitPrice, 6900);
      expect(
        result.vignetteCostPln,
        closeTo(10.8 * eurToPln + hufToPln(6900), 0.01),
      );
    });

    test('passengerCarWithTrailer in HU includes both D1 and U', () async {
      final result = await service.calculateTripCost(
        route: route,
        car: car.copyWithVehicleType(VehicleType.passengerCarWithTrailer),
        tripDays: 10,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: currencyRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
      );

      final huVignettes =
          result.selectedVignettes.where((v) => v.countryCode == 'HU').toList();

      expect(huVignettes, hasLength(2));
      expect(
        huVignettes.map((v) => v.vignetteName).join(' | '),
        contains('D1'),
      );
      expect(
        huVignettes.map((v) => v.vignetteName).join(' | '),
        contains('U trailer'),
      );
      expect(
        result.vignetteCostPln,
        closeTo(10.8 * eurToPln + hufToPln(6900 + 6900), 0.01),
      );
    });

    test('camper and van use HU D2', () async {
      final camperCost = await vignetteCostFor(
        testCar: car.copyWithVehicleType(VehicleType.camper),
      );
      final vanCost = await vignetteCostFor(
        testCar: car.copyWithVehicleType(VehicleType.vanUpTo35t),
      );

      expect(camperCost, closeTo(10.8 * eurToPln + hufToPln(10040), 0.01));
      expect(vanCost, closeTo(10.8 * eurToPln + hufToPln(10040), 0.01));
    });

    test('van on CZ AT SI route uses SI class_2B', () async {
      const alpineRoute = RouteOption(
        id: 'pl_hr_cz_at_si',
        origin: 'Poland',
        destination: 'Croatia',
        distanceKm: 1175,
        durationMinutes: 750,
        countryCodes: ['PL', 'CZ', 'AT', 'SI', 'HR'],
        croatiaEntryGateId: 'trakoscan',
      );

      final result = await service.calculateTripCost(
        route: alpineRoute,
        car: car.copyWithVehicleType(VehicleType.vanUpTo35t),
        tripDays: 7,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: currencyRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
      );

      final siVignette =
          result.selectedVignettes.singleWhere((v) => v.countryCode == 'SI');

      expect(siVignette.vignetteName, contains('class 2B'));
      expect(siVignette.unitPrice, 32.0);
    });

    test('passengerCar Croatia route still resolves tolls with v2 vignettes',
        () async {
      final result = await service.calculateTripCost(
        route: route,
        car: car,
        tripDays: 7,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: currencyRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
        croatiaDestination: splitDestination,
      );

      expect(result.selectedTolls.first.amount, closeTo(30.40, 0.001));
      expect(result.selectedVignettes, isNotEmpty);
    });

    test('falls back to v1 vignettes when v2 rows are missing', () async {
      final result = await legacyFallbackService.calculateTripCost(
        route: route,
        car: car,
        tripDays: 10,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: currencyRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
      );

      expect(
        result.vignetteCostPln,
        closeTo(17.10 * eurToPln + 17.0 * eurToPln, 0.01),
      );
    });
  });

  group('currency conversion fallbacks', () {
    const partialRates = CurrencyRates(
      baseCurrency: 'EUR',
      updatedAt: '',
      rates: {
        'EUR': 1.0,
        'PLN': eurToPln,
      },
    );

    double hufToPlnDefault(double amount) => amount / 354.80 * eurToPln;

    double czkToPlnDefault(double amount) => amount / 24.24 * eurToPln;

    test('HU vignette calculation works when CurrencyRates has no HUF', () async {
      final result = await service.calculateTripCost(
        route: route,
        car: car,
        tripDays: 10,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: partialRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
      );

      final huVignette =
          result.selectedVignettes.singleWhere((v) => v.countryCode == 'HU');

      expect(huVignette.unitPrice, 6900);
      expect(huVignette.currency, 'HUF');
      expect(
        result.vignetteCostPln,
        closeTo(10.8 * eurToPln + hufToPlnDefault(6900), 0.01),
      );
    });

    test('CZ vignette calculation works when CurrencyRates has no CZK', () async {
      const alpineRoute = RouteOption(
        id: 'pl_hr_cz_at_si',
        origin: 'Poland',
        destination: 'Croatia',
        distanceKm: 1175,
        durationMinutes: 750,
        countryCodes: ['PL', 'CZ', 'AT', 'SI', 'HR'],
        croatiaEntryGateId: 'trakoscan',
      );

      final result = await service.calculateTripCost(
        route: alpineRoute,
        car: car,
        tripDays: 10,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: partialRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
      );

      final czVignette =
          result.selectedVignettes.singleWhere((v) => v.countryCode == 'CZ');

      expect(czVignette.unitPrice, 300);
      expect(czVignette.currency, 'CZK');
      expect(czVignette.totalPricePln, closeTo(czkToPlnDefault(300), 0.01));
    });

    test('HUF conversion uses default rate when key is missing', () async {
      final result = await service.calculateTripCost(
        route: route,
        car: car,
        tripDays: 10,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: partialRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
      );

      expect(
        result.selectedVignettes.singleWhere((v) => v.countryCode == 'HU').totalPricePln,
        closeTo(hufToPlnDefault(6900), 0.01),
      );
    });

    test('CZK conversion uses default rate when key is missing', () async {
      const alpineRoute = RouteOption(
        id: 'pl_hr_cz_at_si',
        origin: 'Poland',
        destination: 'Croatia',
        distanceKm: 1175,
        durationMinutes: 750,
        countryCodes: ['PL', 'CZ', 'AT', 'SI', 'HR'],
        croatiaEntryGateId: 'trakoscan',
      );

      final result = await service.calculateTripCost(
        route: alpineRoute,
        car: car,
        tripDays: 10,
        peopleCount: 2,
        fuelPricePln: 6.00,
        eurToPln: eurToPln,
        currencyRates: partialRates,
        tripDirection: TripDirection.oneWay,
        extraDistanceKm: 0,
      );

      expect(
        result.selectedVignettes.singleWhere((v) => v.countryCode == 'CZ').totalPricePln,
        closeTo(czkToPlnDefault(300), 0.01),
      );
    });
  });
}

void _setupLuckoGoricanDugopolje(
  _MockCroatiaEntryAdjustmentRepository entryAdjustmentRepository,
  _MockCroatiaLuckoExitTollRepository luckoExitTollRepository,
) {
  entryAdjustmentRepository.adjustments['gorican'] =
      const CroatiaEntryAdjustment(
    id: 'hr_entry_gorican_to_lucko',
    entryGateId: 'gorican',
    entryGateName: 'Goričan',
    baseGateId: 'lucko',
    baseGateName: 'Zagreb/Lučko',
    amount: 5.80,
    currency: 'EUR',
    accuracy: 'verified',
    source: 'Autopay calculator screenshot',
    lastVerified: '2026-06-10',
  );
  luckoExitTollRepository.exitTolls['dugopolje'] = const CroatiaLuckoExitToll(
    id: 'hr_lucko_dugopolje',
    exitGateId: 'dugopolje',
    exitGateName: 'Dugopolje',
    destinationLabel: 'Split',
    amount: 24.00,
    currency: 'EUR',
    accuracy: 'verified',
    source: 'Autopay calculator screenshot',
    lastVerified: '2026-06-10',
  );
}

extension on Car {
  Car copyWithVehicleType(VehicleType vehicleType) {
    return Car(
      id: id,
      name: name,
      fuelConsumptionLitersPer100Km: fuelConsumptionLitersPer100Km,
      fuelType: fuelType,
      vehicleType: vehicleType,
    );
  }
}

class _EmptyCroatiaTollSegmentsV2Reader implements CroatiaTollSegmentsV2Reader {
  const _EmptyCroatiaTollSegmentsV2Reader();

  @override
  Future<CroatiaTollSegmentV2?> getSegment({
    required String fromGateId,
    required String toGateId,
    required String categoryCode,
  }) async =>
      null;
}

class _EmptyVignettePricesV2LocalSource extends VignettePricesV2LocalSource {
  const _EmptyVignettePricesV2LocalSource() : super(const JsonAssetLoader());

  @override
  Future<List<VehicleCategoryVignettePrice>> getForCountryAndCategory({
    required String countryCode,
    required String categoryCode,
  }) async =>
      [];
}

class _MockVignetteRepository implements VignetteRepository {
  @override
  Future<List<Vignette>> getVignettesForCountries(
    List<String> countryCodes,
  ) async {
    return const [
      Vignette(
        countryCode: 'SK',
        name: 'Slovakia 30-day vignette',
        price: 17.10,
        currency: 'EUR',
        validityDays: 30,
      ),
      Vignette(
        countryCode: 'HU',
        name: 'Hungary 10-day vignette',
        price: 17.0,
        currency: 'EUR',
        validityDays: 10,
      ),
    ];
  }
}

class _MockTollRepository implements TollRepository {
  @override
  Future<List<Toll>> getTollsForRoute(String routeId) async {
    return const [
      Toll(
        id: 'hr_zagreb_makarska',
        routeId: 'pl_hr_sk_hu',
        countryCode: 'HR',
        name: 'Zagreb → Makarska',
        amount: 55.0,
        currency: 'EUR',
      ),
    ];
  }
}

class _MockCroatiaDestinationRepository implements CroatiaDestinationRepository {
  @override
  Future<List<CroatiaDestination>> getAllDestinations() async => [];

  @override
  Future<CroatiaDestination?> getDestinationById(String id) async => null;

  @override
  Future<List<CroatiaDestination>> getPopularDestinations() async => [];

  @override
  Future<CroatiaRegion?> getRegionForDestination(
    CroatiaDestination destination,
  ) async =>
      null;

  @override
  Future<CroatiaToll?> getTollForDestination(
    CroatiaDestination destination,
  ) async =>
      null;
}

class _MockCroatiaEntryAdjustmentRepository
    implements CroatiaEntryAdjustmentRepository {
  final Map<String, CroatiaEntryAdjustment> adjustments = {};

  @override
  Future<CroatiaEntryAdjustment?> getByEntryGateId(String entryGateId) async {
    return adjustments[entryGateId];
  }
}

class _MockCroatiaLuckoExitTollRepository
    implements CroatiaLuckoExitTollRepository {
  final Map<String, CroatiaLuckoExitToll> exitTolls = {};

  @override
  Future<CroatiaLuckoExitToll?> getByExitGateId(String exitGateId) async {
    return exitTolls[exitGateId];
  }
}

class _MockCroatiaTollMatrixRepository implements CroatiaTollMatrixRepository {
  @override
  Future<CroatiaTollMatrixEntry?> getToll({
    required String entryGateId,
    required String exitGateId,
    String vehicleCategory = 'I',
  }) async =>
      null;
}
