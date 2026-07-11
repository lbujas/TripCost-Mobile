import 'package:travel_cost_planner_europe/domain/models/vehicle_type.dart';

class Car {
  const Car({
    required this.id,
    required this.name,
    required this.fuelConsumptionLitersPer100Km,
    required this.fuelType,
    this.vehicleType = VehicleType.passengerCar,
  });

  final String id;
  final String name;
  final double fuelConsumptionLitersPer100Km;
  final String fuelType;
  final VehicleType vehicleType;

  double get consumptionPer100Km => fuelConsumptionLitersPer100Km;

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as String,
      name: json['name'] as String,
      fuelConsumptionLitersPer100Km:
          (json['fuelConsumptionLitersPer100Km'] as num).toDouble(),
      fuelType: json['fuelType'] as String,
      vehicleType: VehicleType.fromStorage(json['vehicleType'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fuelConsumptionLitersPer100Km': fuelConsumptionLitersPer100Km,
      'fuelType': fuelType,
      'vehicleType': vehicleType.storageValue,
    };
  }
}
