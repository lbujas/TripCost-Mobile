import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:travel_cost_planner_europe/core/utils/country_localization_service.dart';
import 'package:travel_cost_planner_europe/core/utils/display_currency_rates.dart';
import 'package:travel_cost_planner_europe/core/utils/formatters.dart';
import 'package:travel_cost_planner_europe/core/utils/money_formatter.dart';
import 'package:travel_cost_planner_europe/core/utils/trip_share_formatter.dart';
import 'package:travel_cost_planner_europe/core/utils/vehicle_type_localization_service.dart';
import 'package:travel_cost_planner_europe/domain/models/currency_rates.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/models/toll.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_result.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_category_speed_limit.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';
import 'package:travel_cost_planner_europe/domain/services/route_speed_limit_resolver.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/ad_banner_layout.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/ad_banner_widget.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/cost_row.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/route_chain.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/section_title.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({
    super.key,
    required this.result,
    this.isAlreadySaved = false,
  });

  final TripResult result;
  final bool isAlreadySaved;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late bool _isSaved;
  bool _isSaving = false;
  CurrencyRates? _repositoryFallbackRates;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isAlreadySaved;
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

  Future<void> _saveToHistory() async {
    if (_isSaved || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tripId = widget.result.id;
      if (tripId != null) {
        final savedTrips =
            await ref.read(tripRepositoryProvider).getSavedTrips();
        if (savedTrips.any((trip) => trip.id == tripId)) {
          if (mounted) {
            setState(() {
              _isSaved = true;
              _isSaving = false;
            });
          }
          return;
        }
      }

      await ref.read(tripRepositoryProvider).saveTrip(widget.result);
      await ref.read(statisticsRepositoryProvider).incrementSavedTripsCount();
      ref.invalidate(savedTripsProvider);
      ref.invalidate(statisticsProvider);

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaved = true;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).tripSaved)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).couldNotSaveTrip),
        ),
      );
    }
  }

  Future<void> _shareResult() async {
    final deviceLocale = Localizations.localeOf(context);
    final displayCurrency = ref.read(displayCurrencyProvider(deviceLocale));
    final rates = _resolveEffectiveRates(ref.read(currencyRatesProvider));

    final text = TripShareFormatter.buildShareText(
      context: context,
      result: widget.result,
      displayCurrency: displayCurrency,
      rates: rates,
    );

    await Share.share(text);
  }

  String _formatMoney(
    BuildContext context,
    double valuePln,
    String displayCurrency,
    CurrencyRates rates,
  ) {
    return DisplayCurrencyRates.formatStoredPln(
      valuePln,
      displayCurrency,
      rates,
      context,
    );
  }

  String _formatToll(
    Toll toll,
    String displayCurrency,
    CurrencyRates rates,
  ) {
    final fallback = '${toll.amount.toStringAsFixed(2)} ${toll.currency}';
    return DisplayCurrencyRates.formatAmountInDisplayCurrency(
      amount: toll.amount,
      sourceCurrency: toll.currency,
      displayCurrency: displayCurrency,
      rates: rates,
      fallbackLabel: fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = AppTextStyles.of(context);
    final deviceLocale = Localizations.localeOf(context);
    final displayCurrency = ref.watch(displayCurrencyProvider(deviceLocale));
    final ratesAsync = ref.watch(currencyRatesProvider);
    final rates = _resolveEffectiveRates(ratesAsync);
    final result = widget.result;
    final routeCountryCodes = result.route.countryCodes
        .map((code) => code.toUpperCase())
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripResult)),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AdBannerLayout.scrollBottomPadding(context),
                ),
                children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.route.origin} → ${result.route.destination}',
                  style: textStyles.subtitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                RouteChain(
                  countryCodes: result.route.countryCodes,
                  compact: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${result.car.name} • ${VehicleTypeLocalizationService.getVehicleTypeName(result.car.vehicleType, context)}',
                  style: textStyles.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.totalTripCost, style: textStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatMoney(
                    context,
                    result.totalCostPln,
                    displayCurrency,
                    rates,
                  ),
                  style: textStyles.amountLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.costPerPerson, style: textStyles.body),
                      Text(
                        _formatMoney(
                          context,
                          result.costPerPersonPln,
                          displayCurrency,
                          rates,
                        ),
                        style: textStyles.title.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionTitle(title: l10n.costBreakdown),
          AppCard(
            child: Column(
              children: [
                CostRow(
                  label: l10n.fuelLiters,
                  value: result.fuelLiters.toStringAsFixed(2),
                ),
                CostRow(
                  label: l10n.fuelCost,
                  value: _formatMoney(
                    context,
                    result.fuelCostPln,
                    displayCurrency,
                    rates,
                  ),
                ),
                CostRow(
                  label: l10n.vignetteCost,
                  value: _formatMoney(
                    context,
                    result.vignetteCostPln,
                    displayCurrency,
                    rates,
                  ),
                ),
                CostRow(
                  label: l10n.tollCost,
                  value: _formatMoney(
                    context,
                    result.tollCostPln,
                    displayCurrency,
                    rates,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionTitle(title: l10n.selectedVignettes),
          if (result.selectedVignettes.isEmpty)
            Text(l10n.noVignettesRequired, style: textStyles.caption)
          else
            ...result.selectedVignettes.map(
              (vignette) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    l10n.vignetteItem(
                      vignette.countryCode,
                      vignette.vignetteName,
                      vignette.quantity,
                      vignette.validDays,
                      _formatMoney(
                        context,
                        vignette.totalPricePln,
                        displayCurrency,
                        rates,
                      ),
                    ),
                    style: textStyles.body,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          SectionTitle(title: l10n.selectedTolls),
          if (result.selectedTolls.isEmpty)
            Text(l10n.noTollsForRoute, style: textStyles.caption)
          else
            ...result.selectedTolls.map(
              (toll) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    '${toll.name} • ${_formatToll(toll, displayCurrency, rates)}',
                    style: textStyles.body,
                  ),
                ),
              ),
            ),
          _VignettePurchaseLinksSection(
            routeCountryCodes: routeCountryCodes,
            textStyles: textStyles,
            colorScheme: colorScheme,
            l10n: l10n,
          ),
          _SpeedLimitsSection(
            routeCountryCodes: routeCountryCodes,
            vehicleType: result.car.vehicleType,
            textStyles: textStyles,
            colorScheme: colorScheme,
            l10n: l10n,
          ),
          _RouteFuelPricesBlock(
            routeCountryCodes: routeCountryCodes,
          ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: _isSaved ? l10n.saved : l10n.saveToHistory,
                      onPressed: _isSaved || _isSaving ? null : _saveToHistory,
                      isLoading: _isSaving,
                      expand: false,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: l10n.shareResult,
                      onPressed: _shareResult,
                      expand: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}

class _RouteFuelPricesBlock extends ConsumerStatefulWidget {
  const _RouteFuelPricesBlock({required this.routeCountryCodes});

  final List<String> routeCountryCodes;

  @override
  ConsumerState<_RouteFuelPricesBlock> createState() =>
      _RouteFuelPricesBlockState();
}

class _RouteFuelPricesBlockState extends ConsumerState<_RouteFuelPricesBlock> {
  static const _fuelPricesUrl = 'http://57.128.246.44:8002/api/fuel-prices';

  _RouteFuelPricesPayload? _payload;
  CurrencyRates? _displayRates;

  @override
  void initState() {
    super.initState();
    _loadFuelPrices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDisplayRates();
    });
  }

  Future<void> _loadDisplayRates() async {
    try {
      final rates = await ref
          .read(currencyRatesRepositoryProvider)
          .getCurrencyRates(forceRemote: true);
      if (!mounted) {
        return;
      }

      setState(() => _displayRates = rates);
    } catch (_) {
      try {
        final rates = await ref
            .read(currencyRatesRepositoryProvider)
            .getCurrencyRates();
        if (!mounted) {
          return;
        }

        setState(() => _displayRates = rates);
      } catch (_) {
        // Keep showing EUR-only conversion until rates are available.
      }
    }
  }

  bool _hasDisplayRates(CurrencyRates rates) {
    const currencies = ['PLN', 'CZK', 'HUF'];
    return currencies.every((code) => rates.rates.containsKey(code));
  }

  CurrencyRates? _resolveDisplayRates(AsyncValue<CurrencyRates> ratesAsync) {
    final displayRates = _displayRates;
    if (displayRates != null && _hasDisplayRates(displayRates)) {
      return displayRates;
    }

    final providerRates = ratesAsync.asData?.value;
    if (providerRates != null && _hasDisplayRates(providerRates)) {
      return providerRates;
    }

    return null;
  }

  Future<void> _loadFuelPrices() async {
    try {
      final response = await http
          .get(Uri.parse(_fuelPricesUrl))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final pricesRaw = decoded['prices'];
      if (pricesRaw is! Map<String, dynamic>) {
        return;
      }

      final pricesByCountry = <String, _CountryFuelPrices>{};
      for (final entry in pricesRaw.entries) {
        if (entry.value is! Map<String, dynamic>) {
          continue;
        }
        final countryPrices = entry.value as Map<String, dynamic>;
        pricesByCountry[entry.key.toUpperCase()] = _CountryFuelPrices(
          petrol95: _readPrice(countryPrices['petrol95']),
          diesel: _readPrice(countryPrices['diesel']),
          lpg: _readPrice(countryPrices['lpg']),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _payload = _RouteFuelPricesPayload(
          source: decoded['source'] as String?,
          updatedAt: decoded['updatedAt'] as String?,
          pricesByCountry: pricesByCountry,
        );
      });
    } catch (_) {
      // Hide section on failure.
    }
  }

  double? _readPrice(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final deviceLocale = Localizations.localeOf(context);
    final displayCurrency = ref.watch(displayCurrencyProvider(deviceLocale));
    final ratesAsync = ref.watch(currencyRatesProvider);
    final rates = _resolveDisplayRates(ratesAsync);

    if (_payload == null) {
      return const SizedBox.shrink();
    }

    if (rates == null) {
      return const SizedBox.shrink();
    }

    final rows = widget.routeCountryCodes
        .map((code) {
          final prices = _payload!.pricesByCountry[code];
          if (prices == null) {
            return null;
          }
          return MapEntry(code, prices);
        })
        .whereType<MapEntry<String, _CountryFuelPrices>>()
        .toList();

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        SectionTitle(title: l10n.fuelPricesOnRoute),
        ...rows.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _CountryAccentCard(
              countryCode: entry.key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FuelTypeCard(
                        icon: Icons.local_gas_station,
                        iconColor: const Color(0xFF4ADE80),
                        label: l10n.fuelPb95Label,
                        display: _formatFuelPriceDisplay(
                          priceEur: entry.value.petrol95,
                          displayCurrency: displayCurrency,
                          rates: rates,
                          notAvailableLabel: l10n.notAvailable,
                        ),
                        textStyles: textStyles,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FuelTypeCard(
                        icon: Icons.local_gas_station,
                        iconColor: const Color(0xFFFB923C),
                        label: l10n.diesel,
                        display: _formatFuelPriceDisplay(
                          priceEur: entry.value.diesel,
                          displayCurrency: displayCurrency,
                          rates: rates,
                          notAvailableLabel: l10n.notAvailable,
                        ),
                        textStyles: textStyles,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FuelTypeCard(
                        icon: Icons.local_fire_department,
                        iconColor: const Color(0xFF60A5FA),
                        label: l10n.lpg,
                        display: _formatFuelPriceDisplay(
                          priceEur: entry.value.lpg,
                          displayCurrency: displayCurrency,
                          rates: rates,
                          notAvailableLabel: l10n.notAvailable,
                        ),
                        textStyles: textStyles,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_payload!.source != null || _payload!.updatedAt != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              l10n.dataSourceUpdated(
                _payload!.source ?? l10n.backendDataSource,
                _formatUpdatedAt(_payload!.updatedAt, l10n.notAvailable),
              ),
              style: textStyles.caption.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Text(
          l10n.fuelPricesApproximateNotice,
          style: textStyles.caption.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  _FuelPriceDisplay _formatFuelPriceDisplay({
    required double? priceEur,
    required String displayCurrency,
    required CurrencyRates rates,
    required String notAvailableLabel,
  }) {
    if (priceEur == null) {
      return _FuelPriceDisplay(notAvailableLabel: notAvailableLabel);
    }

    final eurLabel = '${priceEur.toStringAsFixed(3)} EUR/l';
    final normalizedCurrency = displayCurrency.toUpperCase();

    if (normalizedCurrency == 'EUR') {
      return _FuelPriceDisplay(mainPrice: eurLabel);
    }

    try {
      final convertedLabel =
          '${MoneyFormatter.formatMoneyInDisplayCurrency(priceEur, 'EUR', normalizedCurrency, rates)}/l';
      return _FuelPriceDisplay(
        mainPrice: convertedLabel,
        eurSubtext: eurLabel,
      );
    } catch (_) {
      return _FuelPriceDisplay(mainPrice: eurLabel);
    }
  }

  String _formatUpdatedAt(String? raw, String notAvailableLabel) {
    if (raw == null || raw.isEmpty) {
      return notAvailableLabel;
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return Formatters.formatDate(parsed);
    }
    return raw;
  }
}

class _RouteFuelPricesPayload {
  const _RouteFuelPricesPayload({
    required this.pricesByCountry,
    this.source,
    this.updatedAt,
  });

  final String? source;
  final String? updatedAt;
  final Map<String, _CountryFuelPrices> pricesByCountry;
}

class _CountryFuelPrices {
  const _CountryFuelPrices({
    required this.petrol95,
    required this.diesel,
    required this.lpg,
  });

  final double? petrol95;
  final double? diesel;
  final double? lpg;
}

class _FuelPriceDisplay {
  const _FuelPriceDisplay({
    this.mainPrice,
    this.eurSubtext,
    this.notAvailableLabel,
  });

  final String? mainPrice;
  final String? eurSubtext;
  final String? notAvailableLabel;

  bool get isAvailable => mainPrice != null;
}

class _FuelTypeCard extends StatelessWidget {
  const _FuelTypeCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.display,
    required this.textStyles,
    required this.colorScheme,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final _FuelPriceDisplay display;
  final AppTextStyles textStyles;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: textStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (!display.isAvailable)
              Text(
                display.notAvailableLabel!,
                style: textStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              Text(
                display.mainPrice!,
                style: textStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (display.eurSubtext != null) ...[
                const SizedBox(height: 2),
                Text(
                  display.eurSubtext!,
                  style: textStyles.caption.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _VignettePurchaseLinksSection extends StatelessWidget {
  const _VignettePurchaseLinksSection({
    required this.routeCountryCodes,
    required this.textStyles,
    required this.colorScheme,
    required this.l10n,
  });

  final List<String> routeCountryCodes;
  final AppTextStyles textStyles;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  List<_VignettePurchaseLinkInfo> get _linksForRoute {
    return routeCountryCodes
        .map((code) => _vignettePurchaseLinks[code])
        .whereType<_VignettePurchaseLinkInfo>()
        .toList();
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotOpenLink)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = _linksForRoute;
    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        SectionTitle(title: l10n.officialVignettePurchaseLinks),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CountryLocalizationService.getCountryName(
                      link.countryCode,
                      context,
                    ),
                    style: textStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    link.url,
                    style: textStyles.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.openOfficialWebsite,
                    onPressed: () => _openLink(context, link.url),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VignettePurchaseLinkInfo {
  const _VignettePurchaseLinkInfo({
    required this.countryCode,
    required this.url,
  });

  final String countryCode;
  final String url;
}

const _vignettePurchaseLinks = <String, _VignettePurchaseLinkInfo>{
  'CZ': _VignettePurchaseLinkInfo(
    countryCode: 'CZ',
    url: 'https://edalnice.cz',
  ),
  'SK': _VignettePurchaseLinkInfo(
    countryCode: 'SK',
    url: 'https://eznamka.sk',
  ),
  'HU': _VignettePurchaseLinkInfo(
    countryCode: 'HU',
    url: 'https://ematrica.nemzetiutdij.hu',
  ),
  'AT': _VignettePurchaseLinkInfo(
    countryCode: 'AT',
    url: 'https://shop.asfinag.at',
  ),
  'SI': _VignettePurchaseLinkInfo(
    countryCode: 'SI',
    url: 'https://evinjeta.dars.si',
  ),
};

class _CountryAccentCard extends StatelessWidget {
  const _CountryAccentCard({
    required this.countryCode,
    required this.child,
  });

  final String countryCode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CountryFlagColorStrip(countryCode: countryCode),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CountryLocalizationService.getCountryWithFlag(
                    countryCode,
                    context,
                  ),
                  style: textStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryFlagColorStrip extends StatelessWidget {
  const _CountryFlagColorStrip({required this.countryCode});

  static const _stripHeight = 4.0;
  static const _topRadius = Radius.circular(12);

  final String countryCode;

  static const _white = Color(0xFFF8F8F8);
  static const _red = Color(0xFFDC143C);
  static const _blue = Color(0xFF11457E);
  static const _skBlue = Color(0xFF0B4EA2);
  static const _skRed = Color(0xFFEE1C25);
  static const _huRed = Color(0xFFCE2939);
  static const _huGreen = Color(0xFF477050);
  static const _atRed = Color(0xFFED2939);
  static const _siBlue = Color(0xFF005DA4);
  static const _siRed = Color(0xFFED1C24);
  static const _hrRed = Color(0xFFCC0000);
  static const _hrBlue = Color(0xFF171796);

  List<Color> _colorsFor(String code) {
    return switch (code.toUpperCase()) {
      'PL' => [_white, _red],
      'CZ' => [_white, _red, _blue],
      'SK' => [_white, _skBlue, _skRed],
      'HU' => [_huRed, _white, _huGreen],
      'AT' => [_atRed, _white, _atRed],
      'SI' => [_white, _siBlue, _siRed],
      'HR' => [_hrRed, _white, _hrBlue],
      _ => [const Color(0xFF78909C)],
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(countryCode);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: _topRadius),
      child: SizedBox(
        height: _stripHeight,
        width: double.infinity,
        child: Row(
          children: [
            for (final color in colors)
              Expanded(
                child: ColoredBox(color: color),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpeedLimitsSection extends ConsumerWidget {
  const _SpeedLimitsSection({
    required this.routeCountryCodes,
    required this.vehicleType,
    required this.textStyles,
    required this.colorScheme,
    required this.l10n,
  });

  final List<String> routeCountryCodes;
  final VehicleType vehicleType;
  final AppTextStyles textStyles;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  static const _resolver = RouteSpeedLimitResolver();

  List<RouteSpeedLimitValues> _resolveLimits(
    List<VehicleCategorySpeedLimit>? v2Limits,
  ) {
    final resolutions = _resolver.resolveForRoute(
      routeCountryCodes: routeCountryCodes,
      vehicleType: vehicleType,
      v2Limits: v2Limits,
      fallbackByCountry: _speedLimitsByCountry,
    );

    if (kDebugMode) {
      for (final resolution in resolutions) {
        debugPrint(
          '[TripCostSpeedLimits] countryCode=${resolution.values.countryCode} '
          'vehicleType=${vehicleType.storageValue} '
          'source=${resolution.source.name}',
        );
      }
    }

    return resolutions.map((resolution) => resolution.values).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v2Async = ref.watch(speedLimitsV2ListProvider);
    final limits = v2Async.when(
      data: _resolveLimits,
      loading: () => _resolveLimits(null),
      error: (_, __) => _resolveLimits(null),
    );

    if (limits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        SectionTitle(title: l10n.speedLimitsOnRoute),
        ...limits.map(
          (limit) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _CountryAccentCard(
              countryCode: limit.countryCode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  _SpeedLimitRow(
                    label: l10n.city,
                    speed: limit.city,
                    textStyles: textStyles,
                    notAvailableLabel: l10n.notAvailable,
                  ),
                  _SpeedLimitRow(
                    label: l10n.outsideCity,
                    speed: limit.outsideCity,
                    textStyles: textStyles,
                    notAvailableLabel: l10n.notAvailable,
                  ),
                  _SpeedLimitRow(
                    label: l10n.expressway,
                    speed: limit.expressway,
                    textStyles: textStyles,
                    notAvailableLabel: l10n.notAvailable,
                  ),
                  _SpeedLimitRow(
                    label: l10n.motorway,
                    speed: limit.motorway,
                    textStyles: textStyles,
                    notAvailableLabel: l10n.notAvailable,
                  ),
                ],
              ),
            ),
          ),
        ),
        Text(
          l10n.speedLimitNotice,
          style: textStyles.caption.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SpeedLimitRow extends StatelessWidget {
  const _SpeedLimitRow({
    required this.label,
    required this.speed,
    required this.textStyles,
    required this.notAvailableLabel,
  });

  final String label;
  final int? speed;
  final AppTextStyles textStyles;
  final String notAvailableLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: textStyles.body,
            ),
          ),
          _SpeedLimitSign(
            speed: speed,
            notAvailableLabel: notAvailableLabel,
          ),
        ],
      ),
    );
  }
}

class _SpeedLimitSign extends StatelessWidget {
  const _SpeedLimitSign({
    required this.speed,
    required this.notAvailableLabel,
  });

  final int? speed;
  final String notAvailableLabel;

  @override
  Widget build(BuildContext context) {
    if (speed == null) {
      return Text(
        notAvailableLabel,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
      );
    }

    final fontSize = speed! >= 100 ? 11.0 : 13.0;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.red, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        '$speed',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          height: 1,
        ),
      ),
    );
  }
}

const _speedLimitsByCountry =
    RouteSpeedLimitResolver.resultScreenFallbackByCountry;
