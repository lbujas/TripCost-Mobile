import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';

abstract class CurrencyRatesRepository {
  Future<CurrencyRates> getCurrencyRates({bool forceRemote = false});
}
