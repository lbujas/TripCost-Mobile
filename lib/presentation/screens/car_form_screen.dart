import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/core/utils/fuel_type_localization_service.dart';
import 'package:travel_cost_planner_europe/core/utils/vehicle_type_localization_service.dart';
import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/models/car_fuel_type.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_text_field.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class CarFormScreen extends ConsumerStatefulWidget {
  const CarFormScreen({super.key, this.car});

  final Car? car;

  bool get isEditing => car != null;

  @override
  ConsumerState<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends ConsumerState<CarFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _consumptionController;
  late CarFuelType _selectedFuelType;
  late VehicleType _selectedVehicleType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.car?.name ?? '');
    _selectedFuelType = CarFuelType.fromStorage(widget.car?.fuelType);
    _selectedVehicleType =
        widget.car?.vehicleType ?? VehicleType.passengerCar;
    _consumptionController = TextEditingController(
      text: widget.car?.fuelConsumptionLitersPer100Km.toString() ?? '8.5',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _consumptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final consumption = double.tryParse(
      _consumptionController.text.trim().replaceAll(',', '.'),
    );

    if (name.isEmpty) {
      _showError(l10n.errorEmptyName);
      return;
    }

    if (consumption == null || consumption <= 0) {
      _showError(l10n.errorConsumptionPositive);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(carRepositoryProvider);
      final car = Car(
        id: widget.car?.id ?? 'car_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        fuelType: _selectedFuelType.storageValue,
        fuelConsumptionLitersPer100Km: consumption,
        vehicleType: _selectedVehicleType,
      );

      if (widget.isEditing) {
        await repository.updateCar(car);
      } else {
        await repository.addCar(car);
      }

      ref.invalidate(carsProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        _showError(l10n.couldNotSaveCar);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? l10n.editCar : l10n.addCarTitle),
        actions: const [SettingsActionButton()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(controller: _nameController, label: l10n.vehicleName),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.vehicleType, style: textStyles.body),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<VehicleType>(
                segments: [
                  for (final vehicleType in VehicleType.selectableValues)
                    ButtonSegment(
                      value: vehicleType,
                      label: Text(
                        VehicleTypeLocalizationService.getVehicleTypeName(
                          vehicleType,
                          context,
                        ),
                      ),
                    ),
                ],
                selected: {_selectedVehicleType},
                onSelectionChanged: (selected) {
                  setState(() => _selectedVehicleType = selected.first);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.fuelType, style: textStyles.body),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<CarFuelType>(
                segments: [
                  for (final fuelType in CarFuelType.selectableValues)
                    ButtonSegment(
                      value: fuelType,
                      label: Text(
                        FuelTypeLocalizationService.getFuelTypeNameForEnum(
                          fuelType,
                          context,
                        ),
                      ),
                    ),
                ],
                selected: {_selectedFuelType},
                onSelectionChanged: (selected) {
                  setState(() => _selectedFuelType = selected.first);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _consumptionController,
              label: l10n.consumptionLabel,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
            ),
            AppButton(
              label: widget.isEditing ? l10n.saveChanges : l10n.addCar,
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
