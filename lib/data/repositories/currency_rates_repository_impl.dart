import 'package:travel_cost_planner_europe/core/constants/api_constants.dart';
import 'package:travel_cost_planner_europe/data/sources/currency_rates_cache_source.dart';
import 'package:travel_cost_planner_europe/data/sources/currency_rates_local_source.dart';
import 'package:travel_cost_planner_europe/data/sources/currency_rates_remote_source.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';
import 'package:travel_cost_planner_europe/domain/repositories/currency_rates_repository.dart';

class CurrencyRatesRepositoryImpl implements CurrencyRatesRepository {
  CurrencyRatesRepositoryImpl(
    this._remoteSource,
    this._cacheSource,
    this._localSource,
  );

  final CurrencyRatesRemoteSource _remoteSource;
  final CurrencyRatesCacheSource _cacheSource;
  final CurrencyRatesLocalSource _localSource;

  @override
  Future<CurrencyRates> getCurrencyRates({bool forceRemote = false}) async {
    if (!forceRemote) {
      final freshCache =
          await _cacheSource.loadIfFresh(ApiConstants.exchangeRatesCacheTtl);
      if (freshCache != null) {
        return freshCache;
      }
    }

    try {
      final remoteRates = await _remoteSource.fetchCurrencyRates();
      await _cacheSource.save(remoteRates);
      return remoteRates;
    } catch (_) {
      final cachedRates = await _cacheSource.load();
      if (cachedRates != null) {
        return cachedRates;
      }

      return _localSource.getCurrencyRates();
    }
  }
}
