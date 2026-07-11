import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/domain/models/car_fuel_type.dart';

/// Localizes car fuel type values for display.
class FuelTypeLocalizationService {
  FuelTypeLocalizationService._();

  static String getFuelTypeName(
    String fuelType,
    BuildContext context,
  ) {
    return getFuelTypeNameForEnum(
      CarFuelType.fromStorage(fuelType),
      context,
    );
  }

  static String getFuelTypeNameForEnum(
    CarFuelType fuelType,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context);
    return switch (fuelType) {
      CarFuelType.petrol95 => l10n.petrol,
      CarFuelType.diesel => l10n.diesel,
      CarFuelType.lpg => l10n.lpg,
    };
  }
}
