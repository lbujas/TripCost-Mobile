import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';

/// Hardcoded demo vehicle for MVP trip calculations.
class DemoCar {
  DemoCar._();

  static const Car value = Car(
    id: 'renault-megane-10-tce',
    name: 'Renault Megane 1.0 TCe',
    fuelConsumptionLitersPer100Km: 8.5,
    fuelType: 'PB95',
    vehicleType: VehicleType.passengerCar,
  );
}
