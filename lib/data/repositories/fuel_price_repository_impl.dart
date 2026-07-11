import 'package:travel_cost_planner_europe/core/constants/api_constants.dart';
import 'package:travel_cost_planner_europe/data/sources/fuel_price_cache_source.dart';
import 'package:travel_cost_planner_europe/data/sources/fuel_price_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/fuel_price_remote_source.dart';
import 'package:travel_cost_planner_europe/domain/models/fuel_price.dart';
import 'package:travel_cost_planner_europe/domain/models/fuel_prices_snapshot.dart';
import 'package:travel_cost_planner_europe/domain/repositories/fuel_price_repository.dart';

/// Fuel price repository with backend, cache, and bundled asset fallback.
class FuelPriceRepositoryImpl implements FuelPriceRepository {
  FuelPriceRepositoryImpl(
    this._remoteSource,
    this._cacheSource,
    this._localSource,
  );

  final FuelPriceRemoteSource _remoteSource;
  final FuelPriceCacheSource _cacheSource;
  final FuelPriceLocalSource _localSource;

  @override
  Future<FuelPrice?> getFuelPrice({
    required String countryCode,
    required String fuelType,
  }) {
    return _localSource.getFuelPrice(
      countryCode: countryCode,
      fuelType: fuelType,
    );
  }

  @override
  Future<List<FuelPrice>> getFuelPricesForCountries({
    required List<String> countryCodes,
    required String fuelType,
  }) {
    return _localSource.getFuelPricesForCountries(
      countryCodes: countryCodes,
      fuelType: fuelType,
    );
  }

  @override
  Future<FuelPricesSnapshot> getFuelPricesSnapshot() async {
    final freshCache =
        await _cacheSource.loadIfFresh(ApiConstants.fuelPricesCacheTtl);
    if (freshCache != null) {
      return freshCache;
    }

    try {
      final remoteSnapshot = await _remoteSource.fetchFuelPrices();
      await _cacheSource.save(remoteSnapshot);
      return remoteSnapshot;
    } catch (_) {
      final cachedSnapshot = await _cacheSource.load();
      if (cachedSnapshot != null) {
        return cachedSnapshot;
      }

      return FuelPricesSnapshot.empty();
    }
  }
}
