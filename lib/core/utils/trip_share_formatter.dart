import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/core/utils/country_localization_service.dart';
import 'package:travel_cost_planner_europe/core/utils/croatia_localization_service.dart';
import 'package:travel_cost_planner_europe/core/utils/formatters.dart';
import 'package:travel_cost_planner_europe/core/utils/money_formatter.dart';
import 'package:travel_cost_planner_europe/core/utils/origin_localization_service.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_direction.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_result.dart';

class TripShareFormatter {
  TripShareFormatter._();

  static String buildShareText({
    required BuildContext context,
    required TripResult result,
    required String displayCurrency,
    required CurrencyRates? rates,
  }) {
    final l10n = AppLocalizations.of(context);

    final originCity = result.originCityId != null
        ? OriginLocalizationService.getOriginCityName(
            result.originCityId!,
            context,
            fallbackName: result.originCityName,
          )
        : CountryLocalizationService.getPlaceName(
            result.route.origin,
            context,
          );

    final destination = result.croatiaDestinationId != null
        ? CroatiaLocalizationService.getDestinationName(
            result.croatiaDestinationId!,
            context,
            fallbackName: result.croatiaDestinationName,
          )
        : CountryLocalizationService.getPlaceName(
            result.route.destination,
            context,
          );

    final countryChain = CountryLocalizationService.formatRouteChain(
      result.route.countryCodes,
      context,
    );

    final tripType = result.tripDirection == TripDirection.oneWay
        ? l10n.tripTypeOneWay
        : l10n.tripTypeRoundTrip;

    String formatCost(double valuePln) {
      if (rates == null) {
        return Formatters.formatPln(valuePln);
      }

      return MoneyFormatter.formatMoneyFromPln(
        valuePln,
        displayCurrency,
        rates,
        context,
      );
    }

    final distance = Formatters.formatDistanceKm(result.totalDistanceKm)
        .replaceAll(' km', '');

    return '''
🚗 ${l10n.appTitle}

${l10n.originCity}:
$originCity

${l10n.destinationLabel}:
$destination

${l10n.routeLabel}:
$countryChain

${l10n.tripType}:
$tripType

${l10n.totalCalculatedDistance}:
$distance km

${l10n.fuelCost}:
${formatCost(result.fuelCostPln)}

${l10n.vignetteCost}:
${formatCost(result.vignetteCostPln)}

${l10n.tollCost}:
${formatCost(result.tollCostPln)}

${l10n.totalTripCost}:
${formatCost(result.totalCostPln)}

${l10n.costPerPerson}:
${formatCost(result.costPerPersonPln)}

${l10n.generatedWith(l10n.appTitle)}
''';
  }
}
