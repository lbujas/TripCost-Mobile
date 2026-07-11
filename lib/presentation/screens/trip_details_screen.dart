import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/core/utils/croatia_localization_service.dart';
import 'package:travel_cost_planner_europe/core/utils/fuel_type_localization_service.dart';
import 'package:travel_cost_planner_europe/core/utils/google_maps_launch_utils.dart';
import 'package:travel_cost_planner_europe/core/utils/origin_localization_service.dart';
import 'package:travel_cost_planner_europe/domain/models/app_settings.dart';
import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/models/croatia_destination.dart';
import 'package:travel_cost_planner_europe/domain/models/origin_city.dart';
import 'package:travel_cost_planner_europe/domain/models/trip_direction.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/screens/car_list_screen.dart';
import 'package:travel_cost_planner_europe/presentation/screens/route_comparison_screen.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/ad_banner_widget.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_text_field.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/croatia_destination_picker.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/origin_city_picker.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/section_title.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen for entering trip parameters before route comparison.
class TripDetailsScreen extends ConsumerStatefulWidget {
  const TripDetailsScreen({
    super.key,
    required this.car,
  });

  final Car car;

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  late Car _selectedCar;
  late final TextEditingController _tripDaysController;
  late final TextEditingController _peopleCountController;
  late final TextEditingController _extraDistanceController;
  late final TextEditingController _customDistanceController;
  TripDirection _tripDirection = TripDirection.roundTrip;
  OriginCity? _selectedOriginCity;
  CroatiaDestination? _selectedDestination;
  bool _useCustomDistance = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _selectedCar = widget.car;
    _tripDaysController = TextEditingController();
    _peopleCountController = TextEditingController();
    _extraDistanceController = TextEditingController(text: '0');
    _customDistanceController = TextEditingController();
  }

  @override
  void dispose() {
    _tripDaysController.dispose();
    _peopleCountController.dispose();
    _extraDistanceController.dispose();
    _customDistanceController.dispose();
    super.dispose();
  }

  void _applyDefaults(AppSettings settings) {
    _tripDaysController.text = settings.defaultTripDays.toString();
    _peopleCountController.text = settings.defaultPeopleCount.toString();
    _initialized = true;
  }

  bool _validateInputs({
    required int? tripDays,
    required int? peopleCount,
    required double? extraDistanceKm,
    required double? customDistanceKm,
    required AppLocalizations l10n,
  }) {
    if (tripDays == null || peopleCount == null || extraDistanceKm == null) {
      _showError(l10n.errorInvalidNumbers);
      return false;
    }

    if (_useCustomDistance && customDistanceKm == null) {
      _showError(l10n.errorInvalidNumbers);
      return false;
    }

    if (tripDays <= 0) {
      _showError(l10n.errorAllPositive);
      return false;
    }

    if (peopleCount < 1) {
      _showError(l10n.errorPeopleAtLeastOne);
      return false;
    }

    if (extraDistanceKm < 0) {
      _showError(l10n.errorExtraDistanceNegative);
      return false;
    }

    if (_useCustomDistance && customDistanceKm! <= 0) {
      _showError(l10n.errorCustomDistancePositive);
      return false;
    }

    if (_selectedOriginCity == null) {
      _showError(l10n.errorOriginCityRequired);
      return false;
    }

    if (_selectedDestination == null) {
      _showError(l10n.errorDestinationRequired);
      return false;
    }

    return true;
  }

  void _continue() {
    final l10n = AppLocalizations.of(context);
    final tripDays = int.tryParse(_tripDaysController.text.trim());
    final peopleCount = int.tryParse(_peopleCountController.text.trim());
    final extraDistanceKm = double.tryParse(_extraDistanceController.text.trim());
    final customDistanceKm = _useCustomDistance
        ? double.tryParse(_customDistanceController.text.trim())
        : null;

    if (!_validateInputs(
      tripDays: tripDays,
      peopleCount: peopleCount,
      extraDistanceKm: extraDistanceKm,
      customDistanceKm: customDistanceKm,
      l10n: l10n,
    )) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RouteComparisonScreen(
          selectedCar: _selectedCar,
          tripDays: tripDays!,
          peopleCount: peopleCount!,
          tripDirection: _tripDirection,
          extraDistanceKm: extraDistanceKm!,
          originCity: _selectedOriginCity!,
          croatiaDestination: _selectedDestination!,
          customOneWayDistanceKm: customDistanceKm,
        ),
      ),
    );
  }

  Future<void> _changeCar() async {
    final car = await Navigator.of(context).push<Car>(
      MaterialPageRoute(
        builder: (context) => const CarListScreen(mode: CarListMode.pick),
      ),
    );

    if (car != null && mounted) {
      setState(() => _selectedCar = car);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openInGoogleMaps() async {
    final l10n = AppLocalizations.of(context);
    final origin = _selectedOriginCity;
    final destination = _selectedDestination;

    if (origin == null || destination == null) {
      return;
    }

    setState(() => _useCustomDistance = true);

    final originName = OriginLocalizationService.getOriginCityName(
      origin.id,
      context,
      fallbackName: origin.name,
    );
    final destinationName = CroatiaLocalizationService.getDestinationName(
      destination.id,
      context,
      fallbackName: destination.name,
    );
    final uri = GoogleMapsLaunchUtils.buildDrivingDirectionsUri(
      originCityName: originName,
      destinationName: destinationName,
    );

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      _showError(l10n.couldNotOpenLink);
    }
  }

  Widget _buildOpenInGoogleMapsSection(
    AppLocalizations l10n,
    AppTextStyles textStyles,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openInGoogleMaps,
              icon: const Icon(Icons.map_outlined),
              label: Text(l10n.openInGoogleMaps),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.openInGoogleMapsHint,
            style: textStyles.caption.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistancePreview(AppLocalizations l10n, AppTextStyles textStyles) {
    final colorScheme = Theme.of(context).colorScheme;
    final origin = _selectedOriginCity;
    final destination = _selectedDestination;

    if (origin == null || destination == null) {
      return const SizedBox.shrink();
    }

    final previewAsync = ref.watch(
      estimatedOneWayDistanceProvider(
        (
          originCityId: origin.id,
          croatiaDestinationId: destination.id,
          destinationExtraDistanceKm: destination.extraDistanceKm,
        ),
      ),
    );

    return previewAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(
          l10n.distanceEstimateUnavailable,
          style: textStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      data: (estimate) {
        if (estimate == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.estimatedOneWayDistance(estimate.toStringAsFixed(0)),
                style: textStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.distanceEstimateNotice,
                style: textStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = AppTextStyles.of(context);

    return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            onTap: _changeCar,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedCar.name, style: textStyles.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.fuelConsumption(
                          FuelTypeLocalizationService.getFuelTypeName(
                            _selectedCar.fuelType,
                            context,
                          ),
                          _selectedCar.fuelConsumptionLitersPer100Km.toString(),
                        ),
                        style: textStyles.caption,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionTitle(
            title: l10n.tripSettings,
            subtitle: l10n.tripSettingsSubtitle,
          ),
          OriginCityPickerField(
            selectedCity: _selectedOriginCity,
            onCitySelected: (city) {
              setState(() => _selectedOriginCity = city);
            },
          ),
          CroatiaDestinationPickerField(
            selectedDestination: _selectedDestination,
            onDestinationSelected: (destination) {
              setState(() => _selectedDestination = destination);
            },
          ),
          if (_selectedDestination != null)
            SelectedCroatiaDestinationCard(
              destination: _selectedDestination!,
            ),
          _buildDistancePreview(l10n, textStyles),
          if (_selectedOriginCity != null && _selectedDestination != null)
            _buildOpenInGoogleMapsSection(l10n, textStyles),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _useCustomDistance,
            onChanged: (value) {
              setState(() => _useCustomDistance = value ?? false);
            },
            title: Text(l10n.useCustomDistance, style: textStyles.body),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_useCustomDistance)
            AppTextField(
              controller: _customDistanceController,
              label: l10n.distanceFromGoogleMaps,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tripType, style: textStyles.body),
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<TripDirection>(
                    segments: [
                      ButtonSegment(
                        value: TripDirection.oneWay,
                        label: Text(l10n.tripTypeOneWay),
                      ),
                      ButtonSegment(
                        value: TripDirection.roundTrip,
                        label: Text(l10n.tripTypeRoundTrip),
                      ),
                    ],
                    selected: {_tripDirection},
                    onSelectionChanged: (selected) {
                      setState(() => _tripDirection = selected.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _extraDistanceController,
            label: l10n.extraLocalKilometers,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          AppTextField(
            controller: _tripDaysController,
            label: l10n.tripDays,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          AppTextField(
            controller: _peopleCountController,
            label: l10n.numberOfPeople,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          AppButton(
            label: l10n.compareRoutes,
            onPressed: _continue,
          ),
        ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripDetails),
        actions: const [SettingsActionButton()],
      ),
      body: SafeArea(
        bottom: false,
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) {
            if (!_initialized) {
              _applyDefaults(AppSettings.defaults());
            }
            return _buildForm(l10n);
          },
          data: (settings) {
            if (!_initialized) {
              _applyDefaults(settings);
            }
            return _buildForm(l10n);
          },
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }
}
