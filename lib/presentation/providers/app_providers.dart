import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/core/utils/currency_utils.dart';
import 'package:travel_cost_planner_europe/data/repositories/car_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/currency_rates_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/fuel_price_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/croatia_destination_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/croatia_entry_adjustment_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/croatia_lucko_exit_toll_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/croatia_toll_matrix_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/croatia_region_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/origin_city_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/route_distance_estimate_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/route_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/settings_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/statistics_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/toll_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/trip_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/vignette_purchase_link_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/repositories/vignette_repository_impl.dart';
import 'package:travel_cost_planner_europe/data/sources/car_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/currency_rates_cache_source.dart';
import 'package:travel_cost_planner_europe/data/sources/currency_rates_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/currency_rates_remote_source.dart';
import 'package:travel_cost_planner_europe/data/sources/fuel_price_cache_source.dart';
import 'package:travel_cost_planner_europe/data/sources/fuel_price_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/fuel_price_remote_source.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_destination_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_region_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_toll_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_toll_segments_v2_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_entry_adjustment_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_lucko_exit_toll_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/croatia_toll_matrix_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/origin_city_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/polish_start_cities_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/route_distance_estimate_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/route_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/settings_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/speed_limits_v2_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/statistics_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/toll_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/trip_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/vignette_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/vignette_prices_v2_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/vignette_purchase_link_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/models/app_statistics.dart';
import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_destination.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_region.dart';
import 'package:travel_cost_planner_europe/domain/models/origin_city.dart';
import 'package:travel_cost_planner_europe/domain/models/polish_voivodeship.dart';
import 'package:travel_cost_planner_europe/domain/models/route_option.dart';
import 'package:travel_cost_planner_europe/domain/models/selected_vignette.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_result.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_speed_limit.dart';
import 'package:travel_cost_planner_europe/domain/models/vignette_purchase_link.dart';
import 'package:travel_cost_planner_europe/domain/repositories/car_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/currency_rates_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/fuel_price_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_region_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_entry_adjustment_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_lucko_exit_toll_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/croatia_toll_matrix_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/origin_city_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/route_distance_estimate_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/route_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/settings_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/statistics_repository.dart';
import 'package:travel_cost_planner_europe/domain/services/ad_service.dart';
import 'package:travel_cost_planner_europe/domain/repositories/toll_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/trip_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/vignette_purchase_link_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/vignette_repository.dart';
import 'package:travel_cost_planner_europe/domain/services/cost_calculation_service.dart';
import 'package:travel_cost_planner_europe/domain/services/route_fuel_price_service.dart';

final hiveServiceProvider = Provider<HiveService>(
  (ref) => throw UnimplementedError('HiveService must be overridden in main'),
);

final jsonAssetLoaderProvider = Provider<JsonAssetLoader>(
  (ref) => const JsonAssetLoader(),
);

final currencyRatesLocalSourceProvider = Provider<CurrencyRatesLocalSource>(
  (ref) => CurrencyRatesLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final currencyRatesRemoteSourceProvider = Provider<CurrencyRatesRemoteSource>(
  (ref) => const CurrencyRatesRemoteSource(),
);

final currencyRatesCacheSourceProvider = Provider<CurrencyRatesCacheSource>(
  (ref) => CurrencyRatesCacheSource(ref.watch(hiveServiceProvider)),
);

final currencyRatesRepositoryProvider = Provider<CurrencyRatesRepository>(
  (ref) => CurrencyRatesRepositoryImpl(
    ref.watch(currencyRatesRemoteSourceProvider),
    ref.watch(currencyRatesCacheSourceProvider),
    ref.watch(currencyRatesLocalSourceProvider),
  ),
);

final currencyRatesProvider = FutureProvider<CurrencyRates>((ref) async {
  return ref.watch(currencyRatesRepositoryProvider).getCurrencyRates();
});

final fuelPriceLocalSourceProvider = Provider<FuelPriceLocalSource>(
  (ref) => FuelPriceLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final fuelPriceRemoteSourceProvider = Provider<FuelPriceRemoteSource>(
  (ref) => const FuelPriceRemoteSource(),
);

final fuelPriceCacheSourceProvider = Provider<FuelPriceCacheSource>(
  (ref) => FuelPriceCacheSource(ref.watch(hiveServiceProvider)),
);

final fuelPriceRepositoryProvider = Provider<FuelPriceRepository>(
  (ref) => FuelPriceRepositoryImpl(
    ref.watch(fuelPriceRemoteSourceProvider),
    ref.watch(fuelPriceCacheSourceProvider),
    ref.watch(fuelPriceLocalSourceProvider),
  ),
);

final routeFuelPriceServiceProvider = Provider<RouteFuelPriceService>(
  (ref) => const RouteFuelPriceService(),
);

final routeLocalSourceProvider = Provider<RouteLocalSource>(
  (ref) => RouteLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final originCityLocalSourceProvider = Provider<OriginCityLocalSource>(
  (ref) => OriginCityLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final polishStartCitiesLocalSourceProvider =
    Provider<PolishStartCitiesLocalSource>(
  (ref) => PolishStartCitiesLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final routeDistanceEstimateLocalSourceProvider =
    Provider<RouteDistanceEstimateLocalSource>(
  (ref) => RouteDistanceEstimateLocalSource(
    ref.watch(jsonAssetLoaderProvider),
  ),
);

final carLocalSourceProvider = Provider<CarLocalSource>(
  (ref) => CarLocalSource(ref.watch(hiveServiceProvider)),
);

final tripLocalSourceProvider = Provider<TripLocalSource>(
  (ref) => TripLocalSource(ref.watch(hiveServiceProvider)),
);

final settingsLocalSourceProvider = Provider<SettingsLocalSource>(
  (ref) => SettingsLocalSource(ref.watch(hiveServiceProvider)),
);

final statisticsLocalSourceProvider = Provider<StatisticsLocalSource>(
  (ref) => StatisticsLocalSource(ref.watch(hiveServiceProvider)),
);

final vignetteLocalSourceProvider = Provider<VignetteLocalSource>(
  (ref) => VignetteLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final vignettePricesV2LocalSourceProvider =
    Provider<VignettePricesV2LocalSource>(
  (ref) => VignettePricesV2LocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final vignettePurchaseLinkLocalSourceProvider =
    Provider<VignettePurchaseLinkLocalSource>(
  (ref) => VignettePurchaseLinkLocalSource(
    ref.watch(jsonAssetLoaderProvider),
  ),
);

final tollLocalSourceProvider = Provider<TollLocalSource>(
  (ref) => TollLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final croatiaRegionLocalSourceProvider = Provider<CroatiaRegionLocalSource>(
  (ref) => CroatiaRegionLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final croatiaDestinationLocalSourceProvider =
    Provider<CroatiaDestinationLocalSource>(
  (ref) => CroatiaDestinationLocalSource(
    ref.watch(jsonAssetLoaderProvider),
    ref.watch(hiveServiceProvider),
  ),
);

final croatiaTollLocalSourceProvider = Provider<CroatiaTollLocalSource>(
  (ref) => CroatiaTollLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final croatiaTollMatrixLocalSourceProvider =
    Provider<CroatiaTollMatrixLocalSource>(
  (ref) => CroatiaTollMatrixLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final croatiaEntryAdjustmentLocalSourceProvider =
    Provider<CroatiaEntryAdjustmentLocalSource>(
  (ref) => CroatiaEntryAdjustmentLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final croatiaLuckoExitTollLocalSourceProvider =
    Provider<CroatiaLuckoExitTollLocalSource>(
  (ref) => CroatiaLuckoExitTollLocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final croatiaTollSegmentsV2LocalSourceProvider =
    Provider<CroatiaTollSegmentsV2LocalSource>(
  (ref) => CroatiaTollSegmentsV2LocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final speedLimitsV2LocalSourceProvider = Provider<SpeedLimitsV2LocalSource>(
  (ref) => SpeedLimitsV2LocalSource(ref.watch(jsonAssetLoaderProvider)),
);

final speedLimitsV2ListProvider =
    FutureProvider<List<VehicleCategorySpeedLimit>>((ref) async {
  return ref.watch(speedLimitsV2LocalSourceProvider).getAll();
});

final croatiaEntryAdjustmentRepositoryProvider =
    Provider<CroatiaEntryAdjustmentRepository>(
  (ref) => CroatiaEntryAdjustmentRepositoryImpl(
    ref.watch(croatiaEntryAdjustmentLocalSourceProvider),
  ),
);

final croatiaLuckoExitTollRepositoryProvider =
    Provider<CroatiaLuckoExitTollRepository>(
  (ref) => CroatiaLuckoExitTollRepositoryImpl(
    ref.watch(croatiaLuckoExitTollLocalSourceProvider),
  ),
);

final croatiaTollMatrixRepositoryProvider =
    Provider<CroatiaTollMatrixRepository>(
  (ref) => CroatiaTollMatrixRepositoryImpl(
    ref.watch(croatiaTollMatrixLocalSourceProvider),
  ),
);

final routeRepositoryProvider = Provider<RouteRepository>(
  (ref) => RouteRepositoryImpl(ref.watch(routeLocalSourceProvider)),
);

final originCityRepositoryProvider = Provider<OriginCityRepository>(
  (ref) => OriginCityRepositoryImpl(ref.watch(originCityLocalSourceProvider)),
);

final routeDistanceEstimateRepositoryProvider =
    Provider<RouteDistanceEstimateRepository>(
  (ref) => RouteDistanceEstimateRepositoryImpl(
    ref.watch(routeDistanceEstimateLocalSourceProvider),
  ),
);

final carRepositoryProvider = Provider<CarRepository>(
  (ref) => CarRepositoryImpl(ref.watch(carLocalSourceProvider)),
);

final tripRepositoryProvider = Provider<TripRepository>(
  (ref) => TripRepositoryImpl(ref.watch(tripLocalSourceProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(settingsLocalSourceProvider)),
);

final statisticsRepositoryProvider = Provider<StatisticsRepository>(
  (ref) => StatisticsRepositoryImpl(ref.watch(statisticsLocalSourceProvider)),
);

final statisticsProvider = FutureProvider<AppStatistics>((ref) async {
  return ref.watch(statisticsRepositoryProvider).getStatistics();
});

final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  ref.onDispose(service.dispose);
  return service;
});

final vignetteRepositoryProvider = Provider<VignetteRepository>(
  (ref) => VignetteRepositoryImpl(ref.watch(vignetteLocalSourceProvider)),
);

final vignettePurchaseLinkRepositoryProvider =
    Provider<VignettePurchaseLinkRepository>(
  (ref) => VignettePurchaseLinkRepositoryImpl(
    ref.watch(vignettePurchaseLinkLocalSourceProvider),
  ),
);

final vignettePurchaseLinksProvider =
    FutureProvider<List<VignettePurchaseLink>>((ref) async {
  return ref.watch(vignettePurchaseLinkRepositoryProvider).getAllPurchaseLinks();
});

final vignettePurchaseEntriesProvider = FutureProvider.family<
    List<VignettePurchaseEntry>, List<SelectedVignette>>((ref, vignettes) async {
  return ref
      .watch(vignettePurchaseLinkRepositoryProvider)
      .getPurchaseEntriesForVignettes(vignettes);
});

final tollRepositoryProvider = Provider<TollRepository>(
  (ref) => TollRepositoryImpl(ref.watch(tollLocalSourceProvider)),
);

final croatiaRegionRepositoryProvider = Provider<CroatiaRegionRepository>(
  (ref) => CroatiaRegionRepositoryImpl(
    ref.watch(croatiaRegionLocalSourceProvider),
  ),
);

final croatiaDestinationRepositoryProvider =
    Provider<CroatiaDestinationRepositoryImpl>(
  (ref) => CroatiaDestinationRepositoryImpl(
    ref.watch(croatiaDestinationLocalSourceProvider),
    ref.watch(croatiaRegionLocalSourceProvider),
    ref.watch(croatiaTollLocalSourceProvider),
  ),
);

final routesProvider = FutureProvider<List<RouteOption>>((ref) async {
  return ref.watch(routeRepositoryProvider).getAllRoutes();
});

final carsProvider = FutureProvider<List<Car>>((ref) async {
  return ref.watch(carRepositoryProvider).getCars();
});

final savedTripsProvider = FutureProvider<List<TripResult>>((ref) async {
  return ref.watch(tripRepositoryProvider).getSavedTrips();
});

final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  return ref.watch(settingsRepositoryProvider).getSettings();
});

final displayCurrencyProvider = Provider.family<String, Locale>((
  ref,
  deviceLocale,
) {
  final settings = ref.watch(appSettingsProvider).maybeWhen(
        data: (settings) => settings,
        orElse: () => AppSettings.defaults(),
      );

  return CurrencyUtils.resolveDisplayCurrency(
    settings: settings,
    deviceLocale: deviceLocale,
  );
});

final croatiaDestinationsProvider =
    FutureProvider<List<CroatiaDestination>>((ref) async {
  return ref.watch(croatiaDestinationRepositoryProvider).getAllDestinations();
});

final croatiaRegionsProvider = FutureProvider<List<CroatiaRegion>>((ref) async {
  return ref.watch(croatiaRegionRepositoryProvider).getAllRegions();
});

final originCitiesProvider = FutureProvider<List<OriginCity>>((ref) async {
  return ref.watch(originCityRepositoryProvider).getAllOriginCities();
});

final polishVoivodeshipsProvider =
    FutureProvider<List<PolishVoivodeship>>((ref) async {
  return ref.watch(polishStartCitiesLocalSourceProvider).loadVoivodeships();
});

typedef DistancePreviewRequest = ({
  String originCityId,
  String croatiaDestinationId,
  double destinationExtraDistanceKm,
});

const defaultPreviewRouteId = 'pl_hr_sk_hu';

final estimatedOneWayDistanceProvider =
    FutureProvider.family<double?, DistancePreviewRequest>((ref, request) async {
  return ref
      .watch(routeDistanceEstimateRepositoryProvider)
      .getEstimatedOneWayDistanceKm(
        originCityId: request.originCityId,
        croatiaDestinationId: request.croatiaDestinationId,
        routeId: defaultPreviewRouteId,
        destinationExtraDistanceKm: request.destinationExtraDistanceKm,
        routeFallbackDistanceKm: 1125,
      );
});

final costCalculationServiceProvider = Provider<CostCalculationService>(
  (ref) => CostCalculationService(
    vignetteRepository: ref.watch(vignetteRepositoryProvider),
    vignettePricesV2LocalSource:
        ref.watch(vignettePricesV2LocalSourceProvider),
    tollRepository: ref.watch(tollRepositoryProvider),
    croatiaDestinationRepository:
        ref.watch(croatiaDestinationRepositoryProvider),
    croatiaEntryAdjustmentRepository:
        ref.watch(croatiaEntryAdjustmentRepositoryProvider),
    croatiaLuckoExitTollRepository:
        ref.watch(croatiaLuckoExitTollRepositoryProvider),
    croatiaTollMatrixRepository:
        ref.watch(croatiaTollMatrixRepositoryProvider),
    croatiaTollSegmentsV2Reader:
        ref.watch(croatiaTollSegmentsV2LocalSourceProvider),
  ),
);
