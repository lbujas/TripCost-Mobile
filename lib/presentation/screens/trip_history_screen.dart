import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/core/utils/country_localization_service.dart';
import 'package:travel_cost_planner_europe/core/utils/formatters.dart';
import 'package:travel_cost_planner_europe/core/utils/money_formatter.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_result.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/screens/result_screen.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/ad_banner_widget.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/async_error_view.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/route_chain.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class TripHistoryScreen extends ConsumerWidget {
  const TripHistoryScreen({super.key});

  String _formatTripCost(
    BuildContext context,
    double valuePln,
    String displayCurrency,
    CurrencyRates? rates,
  ) {
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

  Future<void> _deleteTrip(
    BuildContext context,
    WidgetRef ref,
    TripResult trip,
    AppLocalizations l10n,
  ) async {
    final id = trip.id;
    if (id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTrip),
        content: Text(l10n.removeTripQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(tripRepositoryProvider).deleteTrip(id);
    ref.invalidate(savedTripsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final savedTripsAsync = ref.watch(savedTripsProvider);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final deviceLocale = Localizations.localeOf(context);
    final displayCurrency = ref.watch(displayCurrencyProvider(deviceLocale));
    final rates = ref.watch(currencyRatesProvider).maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripHistoryTitle),
        actions: const [SettingsActionButton()],
      ),
      body: Column(
        children: [
          Expanded(
            child: savedTripsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => AsyncErrorView(
                message: l10n.couldNotLoadTrips,
                onRetry: () => ref.invalidate(savedTripsProvider),
              ),
              data: (trips) {
          if (trips.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.noSavedTrips,
                  style: textStyles.subtitle.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: trips.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final trip = trips[index];

              return AppCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => ResultScreen(
                        result: trip,
                        isAlreadySaved: true,
                      ),
                    ),
                  );
                },
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CountryLocalizationService.formatRouteEndpoints(
                              trip.route.origin,
                              trip.route.destination,
                              context,
                            ),
                            style: textStyles.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          RouteChain(
                            countryCodes: trip.route.countryCodes,
                            compact: true,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _formatTripCost(
                              context,
                              trip.totalCostPln,
                              displayCurrency,
                              rates,
                            ),
                            style: textStyles.title,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            l10n.perPerson(
                              _formatTripCost(
                                context,
                                trip.costPerPersonPln,
                                displayCurrency,
                                rates,
                              ),
                            ),
                            style: textStyles.caption,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            trip.car.name,
                            style: textStyles.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (trip.createdAt != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              Formatters.formatDate(trip.createdAt!),
                              style: textStyles.caption,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.deleteTrip,
                      onPressed: () => _deleteTrip(context, ref, trip, l10n),
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
              },
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }
}
