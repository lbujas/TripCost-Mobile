import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';

/// Localizes vehicle type values for display.
class VehicleTypeLocalizationService {
  VehicleTypeLocalizationService._();

  static String getVehicleTypeName(
    VehicleType vehicleType,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context);
    return switch (vehicleType) {
      VehicleType.motorcycle => l10n.vehicleTypeMotorcycle,
      VehicleType.passengerCar => l10n.vehicleTypePassengerCar,
      VehicleType.passengerCarWithTrailer =>
        l10n.vehicleTypePassengerCarWithTrailer,
      VehicleType.camper => l10n.vehicleTypeCamper,
      VehicleType.vanUpTo35t => l10n.vehicleTypeVanUpTo35t,
    };
  }
}
