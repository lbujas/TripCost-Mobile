import 'package:travel_cost_planner_europe/core/constants/demo_car.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/domain/models/car.dart';

/// Local data source for saved vehicles stored in Hive.
class CarLocalSource {
  CarLocalSource(this._hiveService);

  static const String _carsKey = 'cars';
  static const String _initializedKey = 'cars_initialized';

  final HiveService _hiveService;

  Future<List<Car>> getCars() async {
    await _ensureDefaultCar();
    return _readCars();
  }

  Future<void> saveCars(List<Car> cars) async {
    final serialized = cars.map((car) => car.toJson()).toList();
    await _hiveService.carsBox.put(_carsKey, serialized);
  }

  Future<void> addCar(Car car) async {
    await _ensureDefaultCar();
    final cars = _readCars();
    cars.add(car);
    await saveCars(cars);
  }

  Future<void> updateCar(Car car) async {
    await _ensureDefaultCar();
    final cars = _readCars();
    final index = cars.indexWhere((item) => item.id == car.id);
    if (index == -1) {
      throw StateError('Car not found: ${car.id}');
    }
    cars[index] = car;
    await saveCars(cars);
  }

  Future<void> deleteCar(String id) async {
    await _ensureDefaultCar();
    final cars = _readCars();
    cars.removeWhere((car) => car.id == id);
    await saveCars(cars);
  }

  Future<void> _ensureDefaultCar() async {
    final isInitialized =
        _hiveService.settingsBox.get(_initializedKey, defaultValue: false)
            as bool;

    if (isInitialized) {
      return;
    }

    await saveCars([DemoCar.value]);
    await _hiveService.settingsBox.put(_initializedKey, true);
  }

  List<Car> _readCars() {
    final raw =
        _hiveService.carsBox.get(_carsKey, defaultValue: <dynamic>[]) as List;

    return raw
        .map((item) => Car.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
