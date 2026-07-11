import 'package:flutter/foundation.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_toll_segments_v2_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/vignette_prices_v2_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_destination.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll_segment_v2.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';
import 'package:travel_cost_planner_europe/domain/models/origin_city.dart';
import 'package:travel_cost_planner_europe/domain/models/route_option.dart';
import 'package:travel_cost_planner_europe/domain/models/selected_vignette.dart';
import 'package:travel_cost_planner_europe/domain/models/toll.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_direction.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_result.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_vignette_price.dart';
import 'package:travel_cost_planner_europe/domain/models/vignette.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_entry_adjustment.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_lucko_exit_toll.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_toll_matrix_entry.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_destination_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_entry_adjustment_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_lucko_exit_toll_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_toll_matrix_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/toll_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/vignette_repository.dart';
import 'package:travel_cost_planner_europe/domain/services/vehicle_category_mapping_service.dart';

/// Computes fuel, vignette, and toll costs for a planned trip.
class CostCalculationService {
  const CostCalculationService({
    required VignetteRepository vignetteRepository,
    required VignettePricesV2LocalSource vignettePricesV2LocalSource,
    required TollRepository tollRepository,
    required CroatiaDestinationRepository croatiaDestinationRepository,
    required CroatiaEntryAdjustmentRepository croatiaEntryAdjustmentRepository,
    required CroatiaLuckoExitTollRepository croatiaLuckoExitTollRepository,
    required CroatiaTollMatrixRepository croatiaTollMatrixRepository,
    required CroatiaTollSegmentsV2Reader croatiaTollSegmentsV2Reader,
    VehicleCategoryMappingService vehicleCategoryMappingService =
        const VehicleCategoryMappingService(),
  })  : _vignetteRepository = vignetteRepository,
        _vignettePricesV2LocalSource = vignettePricesV2LocalSource,
        _tollRepository = tollRepository,
        _croatiaDestinationRepository = croatiaDestinationRepository,
        _croatiaEntryAdjustmentRepository = croatiaEntryAdjustmentRepository,
        _croatiaLuckoExitTollRepository = croatiaLuckoExitTollRepository,
        _croatiaTollMatrixRepository = croatiaTollMatrixRepository,
        _croatiaTollSegmentsV2Reader = croatiaTollSegmentsV2Reader,
        _vehicleCategoryMappingService = vehicleCategoryMappingService;

  final VignetteRepository _vignetteRepository;
  final VignettePricesV2LocalSource _vignettePricesV2LocalSource;
  final TollRepository _tollRepository;
  final CroatiaDestinationRepository _croatiaDestinationRepository;
  final CroatiaEntryAdjustmentRepository _croatiaEntryAdjustmentRepository;
  final CroatiaLuckoExitTollRepository _croatiaLuckoExitTollRepository;
  final CroatiaTollMatrixRepository _croatiaTollMatrixRepository;
  final CroatiaTollSegmentsV2Reader _croatiaTollSegmentsV2Reader;
  final VehicleCategoryMappingService _vehicleCategoryMappingService;

  static const Set<String> _skippedVignetteCountries = {'PL', 'HR'};
  static const String _luckoGateId = 'lucko';

  static const double _defaultCzkPerEur = 24.24;
  static const double _defaultHufPerEur = 354.80;

  Future<TripResult> calculateTripCost({
    required RouteOption route,
    required Car car,
    required int tripDays,
    required int peopleCount,
    required double fuelPricePln,
    required double eurToPln,
    CurrencyRates? currencyRates,
    required TripDirection tripDirection,
    required double extraDistanceKm,
    CroatiaDestination? croatiaDestination,
    OriginCity? originCity,
    double? estimatedOneWayDistanceKm,
    double? customOneWayDistanceKm,
  }) async {
    if (tripDays <= 0) {
      throw ArgumentError.value(tripDays, 'tripDays', 'Must be greater than 0');
    }
    if (peopleCount <= 0) {
      throw ArgumentError.value(
        peopleCount,
        'peopleCount',
        'Must be greater than 0',
      );
    }
    if (extraDistanceKm < 0) {
      throw ArgumentError.value(
        extraDistanceKm,
        'extraDistanceKm',
        'Must be greater than or equal to 0',
      );
    }
    if (customOneWayDistanceKm != null && customOneWayDistanceKm <= 0) {
      throw ArgumentError.value(
        customOneWayDistanceKm,
        'customOneWayDistanceKm',
        'Must be greater than 0',
      );
    }

    final destinationExtraKm = croatiaDestination?.extraDistanceKm ?? 0;
    final totalExtraKm = extraDistanceKm + destinationExtraKm;
    final resolvedEstimate =
        estimatedOneWayDistanceKm ?? route.oneWayDistanceKm;
    final usedCustomDistance = customOneWayDistanceKm != null;
    final oneWayDistanceKm = customOneWayDistanceKm ?? resolvedEstimate;
    final totalDistanceKm = _calculateTotalDistanceKm(
      oneWayDistanceKm: oneWayDistanceKm,
      tripDirection: tripDirection,
      extraDistanceKm: totalExtraKm,
    );

    final fuelLiters = totalDistanceKm * car.consumptionPer100Km / 100;
    final fuelCostPln = fuelLiters * fuelPricePln;

    final vignetteCountries = route.countryCodes
        .where((code) => !_skippedVignetteCountries.contains(code.toUpperCase()))
        .toList();

    final availableVignettes =
        await _vignetteRepository.getVignettesForCountries(vignetteCountries);

    final selectedVignettes = <SelectedVignette>[];
    var vignetteCostPln = 0.0;

    for (final countryCode in vignetteCountries) {
      final countryResolution = await _resolveCountryVignettes(
        countryCode: countryCode,
        vehicleType: car.vehicleType,
        tripDays: tripDays,
        eurToPln: eurToPln,
        currencyRates: currencyRates,
        v1Options: availableVignettes
            .where(
              (vignette) =>
                  vignette.countryCode.toUpperCase() == countryCode.toUpperCase(),
            )
            .toList(),
      );

      selectedVignettes.addAll(countryResolution.selections);
      vignetteCostPln += countryResolution.totalPln;
    }

    final croatiaTollResolution = croatiaDestination != null
        ? await _resolveCroatiaTolls(
            route: route,
            car: car,
            croatiaDestination: croatiaDestination,
          )
        : _CroatiaTollResolution(
            tolls: await _tollRepository.getTollsForRoute(route.id),
          );
    final tolls = croatiaTollResolution.tolls;

    final tollMultiplier = tripDirection.tollMultiplier;
    final oneWayTollCostPln = tolls.fold<double>(
      0,
      (sum, toll) => sum +
          _convertToPln(
            toll.amount,
            toll.currency,
            eurToPln,
            currencyRates: currencyRates,
          ),
    );
    final totalTollCostPln = oneWayTollCostPln * tollMultiplier;

    final totalCostPln = fuelCostPln + vignetteCostPln + totalTollCostPln;
    final costPerPersonPln = totalCostPln / peopleCount;

    return TripResult(
      route: route,
      car: car,
      tripDays: tripDays,
      peopleCount: peopleCount,
      tripDirection: tripDirection,
      oneWayDistanceKm: oneWayDistanceKm,
      extraDistanceKm: extraDistanceKm,
      totalDistanceKm: totalDistanceKm,
      originCityId: originCity?.id,
      originCityName: originCity?.name,
      estimatedOneWayDistanceKm: resolvedEstimate,
      customOneWayDistanceKm: customOneWayDistanceKm,
      usedCustomDistance: usedCustomDistance,
      croatiaDestinationId: croatiaDestination?.id,
      croatiaDestinationName: croatiaDestination?.name,
      croatiaRegionId: croatiaDestination?.regionId,
      croatiaTollDestination: croatiaTollResolution.croatiaTollDestination,
      croatiaEntryGateId: croatiaTollResolution.croatiaEntryGateId,
      croatiaEntryGateName: croatiaTollResolution.croatiaEntryGateName,
      croatiaExitGateId: croatiaTollResolution.croatiaExitGateId,
      croatiaExitGateName: croatiaTollResolution.croatiaExitGateName,
      croatiaTollAccuracy: croatiaTollResolution.croatiaTollAccuracy,
      croatiaTollSource: croatiaTollResolution.croatiaTollSource,
      croatiaTollBaseGateName: croatiaTollResolution.croatiaTollBaseGateName,
      croatiaTollFallbackUsed: croatiaTollResolution.croatiaTollFallbackUsed,
      croatiaDestinationExtraKm: destinationExtraKm,
      fuelLiters: fuelLiters,
      fuelCostPln: fuelCostPln,
      vignetteCostPln: vignetteCostPln,
      tollMultiplier: tollMultiplier,
      oneWayTollCostPln: oneWayTollCostPln,
      totalTollCostPln: totalTollCostPln,
      tollCostPln: totalTollCostPln,
      totalCostPln: totalCostPln,
      costPerPersonPln: costPerPersonPln,
      selectedVignettes: selectedVignettes,
      selectedTolls: tolls,
    );
  }

  Future<_VignetteCountryResolution> _resolveCountryVignettes({
    required String countryCode,
    required VehicleType vehicleType,
    required int tripDays,
    required double eurToPln,
    CurrencyRates? currencyRates,
    required List<Vignette> v1Options,
  }) async {
    final categoryCodes =
        _vehicleCategoryMappingService.vignetteBillingCategoryCodes(
      countryCode: countryCode,
      vehicleType: vehicleType,
    );

    if (categoryCodes.isEmpty) {
      return const _VignetteCountryResolution(selections: [], totalPln: 0);
    }

    final v2Selections = <SelectedVignette>[];
    var totalPln = 0.0;

    for (final categoryCode in categoryCodes) {
      final v2Prices =
          await _vignettePricesV2LocalSource.getForCountryAndCategory(
        countryCode: countryCode,
        categoryCode: categoryCode,
      );

      if (v2Prices.isEmpty) {
        _logVignetteV2Debug(
          'v2 missing for $countryCode/$categoryCode '
          'vehicleType=${vehicleType.storageValue}; using v1 fallback',
        );
        return _resolveV1CountryVignettes(
          countryCode: countryCode,
          vehicleType: vehicleType,
          tripDays: tripDays,
          eurToPln: eurToPln,
          currencyRates: currencyRates,
          v1Options: v1Options,
        );
      }

      final options = v2Prices.map(_v2PriceToVignette).toList();
      final selection = _selectCheapestVignetteCombination(
        options: options,
        tripDays: tripDays,
        eurToPln: eurToPln,
        currencyRates: currencyRates,
      );

      if (selection.isEmpty) {
        _logVignetteV2Debug(
          'v2 combination empty for $countryCode/$categoryCode '
          'vehicleType=${vehicleType.storageValue}; using v1 fallback',
        );
        return _resolveV1CountryVignettes(
          countryCode: countryCode,
          vehicleType: vehicleType,
          tripDays: tripDays,
          eurToPln: eurToPln,
          currencyRates: currencyRates,
          v1Options: v1Options,
        );
      }

      v2Selections.addAll(selection);
      totalPln += selection.fold<double>(
        0,
        (sum, vignette) => sum + vignette.totalPricePln,
      );
    }

    _logVignetteV2Debug(
      'v2 used for $countryCode vehicleType=${vehicleType.storageValue} '
      'categories=$categoryCodes totalPln=$totalPln',
    );

    return _VignetteCountryResolution(
      selections: v2Selections,
      totalPln: totalPln,
    );
  }

  _VignetteCountryResolution _resolveV1CountryVignettes({
    required String countryCode,
    required VehicleType vehicleType,
    required int tripDays,
    required double eurToPln,
    CurrencyRates? currencyRates,
    required List<Vignette> v1Options,
  }) {
    if (v1Options.isEmpty) {
      return const _VignetteCountryResolution(selections: [], totalPln: 0);
    }

    final selection = _selectCheapestVignetteCombination(
      options: v1Options,
      tripDays: tripDays,
      eurToPln: eurToPln,
      currencyRates: currencyRates,
    );

    return _VignetteCountryResolution(
      selections: selection,
      totalPln: selection.fold<double>(
        0,
        (sum, vignette) => sum + vignette.totalPricePln,
      ),
    );
  }

  Vignette _v2PriceToVignette(VehicleCategoryVignettePrice price) {
    return Vignette(
      countryCode: price.countryCode,
      name: price.name,
      price: price.price,
      currency: price.currency,
      validityDays: price.validityDays,
    );
  }

  Future<_CroatiaTollResolution> _resolveCroatiaTolls({
    required RouteOption route,
    required Car car,
    required CroatiaDestination croatiaDestination,
  }) async {
    final entryGateId = route.croatiaEntryGateId;
    final exitGateId = croatiaDestination.effectiveExitGateId;
    final hrCategory = _vehicleCategoryMappingService
        .getCategoryFor(
          countryCode: 'HR',
          vehicleType: car.vehicleType,
        )
        .categoryCode;

    if (entryGateId != null) {
      final v2Resolution = await _tryResolveCroatiaTollsFromV2(
        routeId: route.id,
        croatiaDestination: croatiaDestination,
        entryGateId: entryGateId,
        exitGateId: exitGateId,
        categoryCode: hrCategory,
        vehicleType: car.vehicleType,
      );
      if (v2Resolution != null) {
        return v2Resolution;
      }

      final entryAdjustment =
          await _croatiaEntryAdjustmentRepository.getByEntryGateId(entryGateId);
      final exitToll =
          await _croatiaLuckoExitTollRepository.getByExitGateId(exitGateId);

      if (entryAdjustment != null && exitToll != null) {
        return _luckoTollResolution(
          routeId: route.id,
          entryAdjustment: entryAdjustment,
          exitToll: exitToll,
          destinationName: croatiaDestination.name,
          entryGateId: entryGateId,
          exitGateId: exitGateId,
        );
      }

      final matrixToll = await _croatiaTollMatrixRepository.getToll(
        entryGateId: entryGateId,
        exitGateId: exitGateId,
      );

      if (matrixToll != null) {
        return _CroatiaTollResolution(
          tolls: [_matrixEntryToToll(matrixToll, route.id)],
          croatiaTollDestination: croatiaDestination.name,
          croatiaEntryGateId: entryGateId,
          croatiaExitGateId: exitGateId,
          croatiaTollAccuracy: matrixToll.accuracy,
          croatiaTollFallbackUsed: true,
        );
      }
    }

    final croatiaToll = await _croatiaDestinationRepository.getTollForDestination(
      croatiaDestination,
    );
    if (croatiaToll != null) {
      return _CroatiaTollResolution(
        tolls: [_toRouteToll(croatiaToll)],
        croatiaTollDestination: croatiaToll.destination,
        croatiaTollFallbackUsed: true,
      );
    }

    return _CroatiaTollResolution(
      tolls: await _tollRepository.getTollsForRoute(route.id),
      croatiaTollFallbackUsed: true,
    );
  }

  Future<_CroatiaTollResolution?> _tryResolveCroatiaTollsFromV2({
    required String routeId,
    required CroatiaDestination croatiaDestination,
    required String entryGateId,
    required String exitGateId,
    required String categoryCode,
    required VehicleType vehicleType,
  }) async {
    final entrySegment = await _croatiaTollSegmentsV2Reader.getSegment(
      fromGateId: entryGateId,
      toGateId: _luckoGateId,
      categoryCode: categoryCode,
    );
    final exitSegment = await _croatiaTollSegmentsV2Reader.getSegment(
      fromGateId: _luckoGateId,
      toGateId: exitGateId,
      categoryCode: categoryCode,
    );

    if (entrySegment == null ||
        exitSegment == null ||
        entrySegment.isMissingPrice ||
        exitSegment.isMissingPrice) {
      _logCroatiaTollV2Debug(
        'v2 segments unavailable for $entryGateId -> $_luckoGateId -> '
        '$exitGateId category $categoryCode; using legacy Croatia fallbacks',
      );
      return null;
    }

    final resolution = _v2LuckoTollResolution(
      routeId: routeId,
      entrySegment: entrySegment,
      exitSegment: exitSegment,
      destinationName: croatiaDestination.name,
      entryGateId: entryGateId,
      exitGateId: exitGateId,
      categoryCode: categoryCode,
    );

    _logCroatiaTollV2Debug(
      'HR category=$categoryCode vehicleType=${vehicleType.storageValue} '
      'entrySegmentId=${entrySegment.id} exitSegmentId=${exitSegment.id} '
      'amount=${resolution.tolls.first.amount}',
    );

    return resolution;
  }

  _CroatiaTollResolution _v2LuckoTollResolution({
    required String routeId,
    required CroatiaTollSegmentV2 entrySegment,
    required CroatiaTollSegmentV2 exitSegment,
    required String destinationName,
    required String entryGateId,
    required String exitGateId,
    required String categoryCode,
  }) {
    final amount = entrySegment.amount + exitSegment.amount;
    final accuracy = entrySegment.accuracy == 'verified' &&
            exitSegment.accuracy == 'verified'
        ? 'verified'
        : 'estimated';
    final source = _combineTollSources([
      entrySegment.source,
      exitSegment.source,
    ]);
    final tollName =
        '${entrySegment.fromGateName} → ${entrySegment.toGateName} + '
        '${exitSegment.fromGateName} → ${exitSegment.toGateName}';

    return _CroatiaTollResolution(
      tolls: [
        Toll(
          id: 'hr_v2_${entryGateId}_${exitGateId}_$categoryCode',
          routeId: routeId,
          countryCode: 'HR',
          name: tollName,
          amount: amount,
          currency: entrySegment.currency,
        ),
      ],
      croatiaTollDestination: destinationName,
      croatiaEntryGateId: entryGateId,
      croatiaEntryGateName: entrySegment.fromGateName,
      croatiaExitGateId: exitGateId,
      croatiaExitGateName: exitSegment.toGateName,
      croatiaTollAccuracy: accuracy,
      croatiaTollSource: source,
      croatiaTollBaseGateName: entrySegment.toGateName,
    );
  }

  _CroatiaTollResolution _luckoTollResolution({
    required String routeId,
    required CroatiaEntryAdjustment entryAdjustment,
    required CroatiaLuckoExitToll exitToll,
    required String destinationName,
    required String entryGateId,
    required String exitGateId,
  }) {
    final amount = entryAdjustment.amount + exitToll.amount;
    final accuracy = entryAdjustment.isVerified && exitToll.isVerified
        ? 'verified'
        : 'estimated';
    final source = _combineTollSources([
      entryAdjustment.source,
      exitToll.source,
    ]);
    final tollName =
        '${entryAdjustment.entryGateName} → ${entryAdjustment.baseGateName} + '
        '${entryAdjustment.baseGateName} → ${exitToll.exitGateName}';

    return _CroatiaTollResolution(
      tolls: [
        Toll(
          id: 'hr_lucko_${entryGateId}_$exitGateId',
          routeId: routeId,
          countryCode: 'HR',
          name: tollName,
          amount: amount,
          currency: entryAdjustment.currency,
        ),
      ],
      croatiaTollDestination: destinationName,
      croatiaEntryGateId: entryGateId,
      croatiaEntryGateName: entryAdjustment.entryGateName,
      croatiaExitGateId: exitGateId,
      croatiaExitGateName: exitToll.exitGateName,
      croatiaTollAccuracy: accuracy,
      croatiaTollSource: source,
      croatiaTollBaseGateName: entryAdjustment.baseGateName,
    );
  }

  Toll _toRouteToll(CroatiaToll croatiaToll) {
    return Toll(
      id: croatiaToll.id,
      routeId: 'croatia',
      countryCode: croatiaToll.countryCode,
      name: 'Zagreb → ${croatiaToll.destination}',
      amount: croatiaToll.amount,
      currency: croatiaToll.currency,
    );
  }

  Toll _matrixEntryToToll(CroatiaTollMatrixEntry entry, String routeId) {
    return Toll(
      id: entry.id,
      routeId: routeId,
      countryCode: 'HR',
      name: '${entry.entryGateId} → ${entry.exitGateId}',
      amount: entry.amount,
      currency: entry.currency,
    );
  }

  List<SelectedVignette> _selectCheapestVignetteCombination({
    required List<Vignette> options,
    required int tripDays,
    required double eurToPln,
    CurrencyRates? currencyRates,
  }) {
    final maxValidityDays = options
        .map((option) => option.validityDays)
        .reduce((a, b) => a > b ? a : b);
    final maxCoveredDays = tripDays + maxValidityDays - 1;

    final minCostByDays = List<double>.filled(maxCoveredDays + 1, double.infinity);
    final previousChoiceByDays =
        List<_VignetteChoice?>.filled(maxCoveredDays + 1, null);

    minCostByDays[0] = 0;

    for (var coveredDays = 0; coveredDays <= maxCoveredDays; coveredDays++) {
      if (minCostByDays[coveredDays].isInfinite) {
        continue;
      }

      for (final option in options) {
        final nextCoveredDays = coveredDays + option.validityDays;
        if (nextCoveredDays > maxCoveredDays) {
          continue;
        }

        final nextCost = minCostByDays[coveredDays] +
            _convertToPln(
              option.price,
              option.currency,
              eurToPln,
              currencyRates: currencyRates,
            );

        if (nextCost < minCostByDays[nextCoveredDays]) {
          minCostByDays[nextCoveredDays] = nextCost;
          previousChoiceByDays[nextCoveredDays] = _VignetteChoice(
            previousCoveredDays: coveredDays,
            vignette: option,
          );
        }
      }
    }

    var bestCoveredDays = tripDays;
    for (var coveredDays = tripDays + 1; coveredDays <= maxCoveredDays; coveredDays++) {
      if (minCostByDays[coveredDays] < minCostByDays[bestCoveredDays]) {
        bestCoveredDays = coveredDays;
      }
    }

    if (minCostByDays[bestCoveredDays].isInfinite) {
      return const [];
    }

    final counts = <Vignette, int>{};
    var coveredDays = bestCoveredDays;

    while (coveredDays > 0) {
      final choice = previousChoiceByDays[coveredDays];
      if (choice == null) {
        break;
      }

      counts[choice.vignette] = (counts[choice.vignette] ?? 0) + 1;
      coveredDays = choice.previousCoveredDays;
    }

    return counts.entries.map((entry) {
      final vignette = entry.key;
      final quantity = entry.value;
      final unitPricePln = _convertToPln(
        vignette.price,
        vignette.currency,
        eurToPln,
        currencyRates: currencyRates,
      );

      return SelectedVignette(
        countryCode: vignette.countryCode,
        vignetteName: vignette.name,
        validDays: vignette.validityDays,
        quantity: quantity,
        unitPrice: vignette.price,
        currency: vignette.currency,
        totalPricePln: unitPricePln * quantity,
      );
    }).toList();
  }

  double _calculateTotalDistanceKm({
    required double oneWayDistanceKm,
    required TripDirection tripDirection,
    required double extraDistanceKm,
  }) {
    return switch (tripDirection) {
      TripDirection.oneWay => oneWayDistanceKm + extraDistanceKm,
      TripDirection.roundTrip => oneWayDistanceKm * 2 + extraDistanceKm,
    };
  }

  double _convertToPln(
    double amount,
    String currency,
    double eurToPln, {
    CurrencyRates? currencyRates,
  }) {
    switch (currency.toUpperCase()) {
      case 'PLN':
        return amount;
      case 'EUR':
        return amount * eurToPln;
      case 'CZK':
        final czkPerEur =
            currencyRates?.rates['CZK'] ?? _defaultCzkPerEur;
        return amount / czkPerEur * eurToPln;
      case 'HUF':
        final hufPerEur =
            currencyRates?.rates['HUF'] ?? _defaultHufPerEur;
        return amount / hufPerEur * eurToPln;
      default:
        return amount * eurToPln;
    }
  }

  static String _combineTollSources(Iterable<String> sources) {
    final seen = <String>{};
    final parts = <String>[];

    for (final source in sources) {
      for (final part in source.split(';')) {
        final trimmed = part.trim();
        if (trimmed.isNotEmpty && seen.add(trimmed)) {
          parts.add(trimmed);
        }
      }
    }

    return parts.join('; ');
  }

  static void _logCroatiaTollV2Debug(String message) {
    if (kDebugMode) {
      debugPrint('[TripCostCroatiaTolls] $message');
    }
  }

  static void _logVignetteV2Debug(String message) {
    if (kDebugMode) {
      debugPrint('[TripCostVignettes] $message');
    }
  }
}

class _CroatiaTollResolution {
  const _CroatiaTollResolution({
    required this.tolls,
    this.croatiaTollDestination,
    this.croatiaEntryGateId,
    this.croatiaEntryGateName,
    this.croatiaExitGateId,
    this.croatiaExitGateName,
    this.croatiaTollAccuracy,
    this.croatiaTollSource,
    this.croatiaTollBaseGateName,
    this.croatiaTollFallbackUsed = false,
  });

  final List<Toll> tolls;
  final String? croatiaTollDestination;
  final String? croatiaEntryGateId;
  final String? croatiaEntryGateName;
  final String? croatiaExitGateId;
  final String? croatiaExitGateName;
  final String? croatiaTollAccuracy;
  final String? croatiaTollSource;
  final String? croatiaTollBaseGateName;
  final bool croatiaTollFallbackUsed;
}

class _VignetteChoice {
  const _VignetteChoice({
    required this.previousCoveredDays,
    required this.vignette,
  });

  final int previousCoveredDays;
  final Vignette vignette;
}

class _VignetteCountryResolution {
  const _VignetteCountryResolution({
    required this.selections,
    required this.totalPln,
  });

  final List<SelectedVignette> selections;
  final double totalPln;
}
