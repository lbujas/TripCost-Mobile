import 'package:travel_cost_planner_europe/domain/models/car.dart';

/// Contract for persisting and retrieving user vehicles.
abstract class CarRepository {
  Future<List<Car>> getCars();

  Future<void> addCar(Car car);

  Future<void> updateCar(Car car);

  Future<void> deleteCar(String id);
}
