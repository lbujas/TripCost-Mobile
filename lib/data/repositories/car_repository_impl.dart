import 'package:travel_cost_planner_europe/data/sources/car_local_source.dart';
import 'package:travel_cost_planner_europe/domain/models/car.dart';
import 'package:travel_cost_planner_europe/domain/repositories/car_repository.dart';

/// Data-layer implementation of [CarRepository] using Hive storage.
class CarRepositoryImpl implements CarRepository {
  CarRepositoryImpl(this._localSource);

  final CarLocalSource _localSource;

  @override
  Future<List<Car>> getCars() {
    return _localSource.getCars();
  }

  @override
  Future<void> addCar(Car car) {
    return _localSource.addCar(car);
  }

  @override
  Future<void> updateCar(Car car) {
    return _localSource.updateCar(car);
  }

  @override
  Future<void> deleteCar(String id) {
    return _localSource.deleteCar(id);
  }
}
