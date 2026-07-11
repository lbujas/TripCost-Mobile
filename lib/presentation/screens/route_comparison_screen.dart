import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/core/utils/display_currency_rates.dart';
import 'package:travel_cost_planner_europe/core/utils/formatters.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';
import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_destination.dart';
import 'package:travel_cost_planner_europe/domain/models/origin_city.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_direction.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_result.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/screens/result_screen.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/ad_banner_widget.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/cost_row.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/route_chain.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/section_title.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

/// Compares trip costs across Poland → Croatia routes.
class RouteComparisonScreen extends ConsumerStatefulWidget {
  const RouteComparisonScreen({
    super.key,
    required this.selectedCar,
    required this.tripDays,
    required this.peopleCount,
    required this.tripDirection,
    required this.extraDistanceKm,
    required this.originCity,
    required this.croatiaDestination,
    this.customOneWayDistanceKm,
  });

  final Car selectedCar;
  final int tripDays;
  final int peopleCount;
  final TripDirection tripDirection;
  final double extraDistanceKm;
  final OriginCity originCity;
  final CroatiaDestination croatiaDestination;
  final double? customOneWayDistanceKm;

  @override
  ConsumerState<RouteComparisonScreen> createState() =>
      _RouteComparisonScreenState();
}

class _RouteComparisonScreenState extends ConsumerState<RouteComparisonScreen> {
  List<TripResult>? _results;
  Object? _error;
  CurrencyRates? _repositoryFallbackRates;

  @override
  void initState() {
    super.initState();
    _loadComparisons();
    _loadRepositoryFallbackRates();
  }

  Future<void> _loadRepositoryFallbackRates() async {
    try {
      final rates =
          await ref.read(currencyRatesRepositoryProvider).getCurrencyRates();
      if (!mounted) {
        return;
      }

      setState(() => _repositoryFallbackRates = rates);
    } catch (_) {
      // Settings/asset fallback is used instead.
    }
  }

  CurrencyRates _resolveEffectiveRates(AsyncValue<CurrencyRates> ratesAsync) {
    final settings = ref.watch(appSettingsProvider).maybeWhen(
          data: (value) => value,
          orElse: () => AppSettings.defaults(),
        );

    return DisplayCurrencyRates.resolve(
      ratesAsync: ratesAsync,
      settings: settings,
      repositoryFallback: _repositoryFallbackRates,
    );
  }

  Future<void> _loadComparisons() async {
    try {
      final routes = (await ref.read(routeRepositoryProvider).getAllRoutes())
          .where(
            (route) =>
                route.origin == 'Poland' && route.destination == 'Croatia',
          )
          .toList();
      final service = ref.read(costCalculationServiceProvider);
      final estimateRepository =
          ref.read(routeDistanceEstimateRepositoryProvider);
      final settings = await ref.read(settingsRepositoryProvider).getSettings();
      var eurToPln = settings.defaultEurToPln;
      CurrencyRates rates;
      try {
        rates =
            await ref.read(currencyRatesRepositoryProvider).getCurrencyRates();
        eurToPln = rates.rateFor('PLN');
      } catch (_) {
        rates = CurrencyRates(
          baseCurrency: 'EUR',
          updatedAt: '',
          rates: {
            'EUR': 1.0,
            'PLN': settings.defaultEurToPln,
          },
        );
        eurToPln = settings.defaultEurToPln;
      }

      final fuelSnapshot =
          await ref.read(fuelPriceRepositoryProvider).getFuelPricesSnapshot();
      final fuelPriceService = ref.read(routeFuelPriceServiceProvider);
      final results = <TripResult>[];

      for (final route in routes) {
        final fuelPricePln = fuelPriceService.resolveAverageFuelPricePln(
          countryCodes: route.countryCodes,
          car: widget.selectedCar,
          snapshot: fuelSnapshot,
          rates: rates,
          fallbackFuelPricePln: settings.defaultFuelPricePln,
        );

        final estimatedOneWayDistanceKm =
            await estimateRepository.getEstimatedOneWayDistanceKm(
          originCityId: widget.originCity.id,
          croatiaDestinationId: widget.croatiaDestination.id,
          routeId: route.id,
          destinationExtraDistanceKm:
              widget.croatiaDestination.extraDistanceKm,
          routeFallbackDistanceKm: route.oneWayDistanceKm,
        );

        results.add(
          await service.calculateTripCost(
            route: route,
            car: widget.selectedCar,
            tripDays: widget.tripDays,
            peopleCount: widget.peopleCount,
            fuelPricePln: fuelPricePln,
            eurToPln: eurToPln,
            currencyRates: rates,
            tripDirection: widget.tripDirection,
            extraDistanceKm: widget.extraDistanceKm,
            croatiaDestination: widget.croatiaDestination,
            originCity: widget.originCity,
            estimatedOneWayDistanceKm: estimatedOneWayDistanceKm,
            customOneWayDistanceKm: widget.customOneWayDistanceKm,
          ),
        );
      }

      results.sort((a, b) => a.totalCostPln.compareTo(b.totalCostPln));

      if (!mounted) {
        return;
      }

      await ref.read(statisticsRepositoryProvider).incrementCalculationsCount();
      final statistics =
          await ref.read(statisticsRepositoryProvider).getStatistics();
      ref.invalidate(statisticsProvider);

      if (!mounted) {
        return;
      }

      setState(() {
        _results = results;
        _error = null;
      });

      unawaited(
        ref.read(adServiceProvider).showInterstitialIfNeeded(
              statistics.calculationsCount,
            ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
        _results = null;
      });
    }
  }

  void _openResult(TripResult result) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ResultScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final ratesAsync = ref.watch(currencyRatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.compareRoutesTitle),
        actions: const [SettingsActionButton()],
      ),
      body: SafeArea(
        bottom: false,
        child: _buildBody(context, l10n, textStyles, ratesAsync),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    AppTextStyles textStyles,
    AsyncValue<CurrencyRates> ratesAsync,
  ) {
    final rates = _resolveEffectiveRates(ratesAsync);

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.couldNotLoadData,
                style: textStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.retry,
                onPressed: _loadComparisons,
              ),
            ],
          ),
        ),
      );
    }

    if (_results == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            l10n.noRoutesFound,
            style: textStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionTitle(
          title: widget.selectedCar.name,
          subtitle: l10n.daysPeopleRoute(
            widget.tripDays,
            widget.peopleCount,
          ),
        ),
        for (var index = 0; index < _results!.length; index++) ...[
          _ComparisonCard(
            result: _results![index],
            rankIndex: index,
            isBestPrice: index == 0,
            onTap: () => _openResult(_results![index]),
            rates: rates,
            displayCurrency: ref.watch(
              displayCurrencyProvider(Localizations.localeOf(context)),
            ),
          ),
          if (index < _results!.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
        if (ratesAsync case AsyncData(:final value)) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.currencyRatesUpdated(value.updatedAt),
            style: textStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _ComparisonCard extends ConsumerWidget {
  const _ComparisonCard({
    required this.result,
    required this.rankIndex,
    required this.isBestPrice,
    required this.onTap,
    required this.rates,
    required this.displayCurrency,
  });

  final TripResult result;
  final int rankIndex;
  final bool isBestPrice;
  final VoidCallback onTap;
  final CurrencyRates rates;
  final String displayCurrency;

  static const _tealAccent = Color(0xFF2DD4BF);
  static const _orangeAccent = Color(0xFFFB923C);
  static const _purpleAccent = Color(0xFFC084FC);

  Color? get _accentColor => switch (rankIndex) {
        0 => _tealAccent,
        1 => _orangeAccent,
        2 => _purpleAccent,
        _ => null,
      };

  List<BoxShadow>? get _glowShadow {
    final accent = _accentColor;
    if (accent == null) {
      return null;
    }

    return [
      BoxShadow(
        color: accent.withValues(alpha: 0.28),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ];
  }

  String _formatCost(BuildContext context, double valuePln) {
    return DisplayCurrencyRates.formatStoredPln(
      valuePln,
      displayCurrency,
      rates,
      context,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = AppTextStyles.of(context);
    final accent = _accentColor;
    final badgeColor = accent ?? colorScheme.primary;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RouteChain(countryCodes: result.route.countryCodes),
            ),
            if (isBestPrice)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: accent != null
                      ? Border.all(
                          color: badgeColor.withValues(alpha: 0.45),
                        )
                      : null,
                ),
                child: Text(
                  l10n.bestPrice,
                  style: textStyles.caption.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          Formatters.formatDistanceKm(result.totalDistanceKm),
          style: textStyles.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _formatCost(context, result.totalCostPln),
          style: textStyles.amountLarge.copyWith(
            color: accent ?? colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        CostRow(
          label: l10n.costPerPerson,
          value: _formatCost(context, result.costPerPersonPln),
          emphasized: true,
        ),
        CostRow(
          label: l10n.fuelCost,
          value: _formatCost(context, result.fuelCostPln),
        ),
        CostRow(
          label: l10n.vignetteCost,
          value: _formatCost(context, result.vignetteCostPln),
        ),
        CostRow(
          label: l10n.tollCost,
          value: _formatCost(context, result.tollCostPln),
        ),
      ],
    );

    if (accent == null) {
      return AppCard(onTap: onTap, child: content);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent, width: 1.75),
            boxShadow: _glowShadow,
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: content,
        ),
      ),
    );
  }
}
