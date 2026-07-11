import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/core/utils/country_localization_service.dart';
import 'package:travel_cost_planner_europe/core/utils/fuel_type_localization_service.dart';
import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/models/route_option.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/screens/car_form_screen.dart';
import 'package:travel_cost_planner_europe/presentation/screens/trip_details_screen.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/async_error_view.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

enum CarListMode { manage, select, pick }

/// Screen for viewing and managing saved vehicles.
class CarListScreen extends ConsumerWidget {
  const CarListScreen({
    super.key,
    this.mode = CarListMode.manage,
    this.route,
  });

  final CarListMode mode;
  final RouteOption? route;

  bool get isPickerUi =>
      mode == CarListMode.select || mode == CarListMode.pick;

  bool get popOnSelect => mode == CarListMode.pick;

  Future<void> _openCarForm(BuildContext context, WidgetRef ref, {Car? car}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => CarFormScreen(car: car),
      ),
    );

    if (saved == true) {
      ref.invalidate(carsProvider);
    }
  }

  Future<void> _deleteCar(
    BuildContext context,
    WidgetRef ref,
    Car car,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCar),
        content: Text(l10n.removeCarQuestion(car.name)),
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

    await ref.read(carRepositoryProvider).deleteCar(car.id);
    ref.invalidate(carsProvider);
  }

  void _selectCar(BuildContext context, Car car) {
    if (popOnSelect) {
      Navigator.of(context).pop(car);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TripDetailsScreen(car: car),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final carsAsync = ref.watch(carsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = AppTextStyles.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isPickerUi ? l10n.selectCar : l10n.myCars),
        actions: [
          if (!isPickerUi)
            IconButton(
              onPressed: () => _openCarForm(context, ref),
              icon: const Icon(Icons.add),
              tooltip: l10n.addCarTooltip,
            ),
          const SettingsActionButton(),
        ],
      ),
      body: carsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => AsyncErrorView(
          message: l10n.couldNotLoadData,
          onRetry: () => ref.invalidate(carsProvider),
        ),
        data: (cars) {
          if (cars.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.noCarsYet, style: textStyles.title),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.noCarsSubtitle,
                    style: textStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.addFirstCar,
                    onPressed: () => _openCarForm(context, ref),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (isPickerUi)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Text(
                    route == null
                        ? l10n.chooseCarForTrip
                        : l10n.chooseCarForRoute(
                            CountryLocalizationService.getPlaceName(
                              route!.origin,
                              context,
                            ),
                            CountryLocalizationService.getPlaceName(
                              route!.destination,
                              context,
                            ),
                          ),
                    style: textStyles.subtitle.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              for (var index = 0; index < cars.length; index++) ...[
                AppCard(
                  onTap:
                      isPickerUi ? () => _selectCar(context, cars[index]) : null,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_car_filled_outlined,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cars[index].name,
                              style: textStyles.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.fuelConsumption(
                                FuelTypeLocalizationService.getFuelTypeName(
                                  cars[index].fuelType,
                                  context,
                                ),
                                cars[index].fuelConsumptionLitersPer100Km
                                    .toString(),
                              ),
                              style: textStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      if (isPickerUi)
                        Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
                        )
                      else
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _openCarForm(context, ref, car: cars[index]);
                              case 'delete':
                                _deleteCar(context, ref, cars[index], l10n);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(l10n.edit),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                l10n.delete,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (index < cars.length - 1)
                  const SizedBox(height: AppSpacing.md),
              ],
              if (!isPickerUi) ...[
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.addCar,
                  onPressed: () => _openCarForm(context, ref),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: isPickerUi && carsAsync.maybeWhen(
            data: (cars) => cars.isNotEmpty,
            orElse: () => false,
          )
          ? FloatingActionButton(
              onPressed: () => _openCarForm(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
