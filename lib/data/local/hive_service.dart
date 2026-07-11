import 'package:hive_flutter/hive_flutter.dart';

/// Hive initialization and box access.
class HiveService {
  HiveService(
    this._carsBox,
    this._settingsBox,
    this._tripsBox,
    this._statisticsBox,
  );

  static const String carsBoxName = 'cars_box';
  static const String settingsBoxName = 'settings_box';
  static const String tripsBoxName = 'trips_box';
  static const String statisticsBoxName = 'statistics_box';

  final Box<dynamic> _carsBox;
  final Box<dynamic> _settingsBox;
  final Box<dynamic> _tripsBox;
  final Box<dynamic> _statisticsBox;

  Box<dynamic> get carsBox => _carsBox;
  Box<dynamic> get settingsBox => _settingsBox;
  Box<dynamic> get tripsBox => _tripsBox;
  Box<dynamic> get statisticsBox => _statisticsBox;

  static Future<HiveService> init() async {
    await Hive.initFlutter();
    return open();
  }

  static Future<HiveService> open() async {
    final carsBox = await Hive.openBox<dynamic>(carsBoxName);
    final settingsBox = await Hive.openBox<dynamic>(settingsBoxName);
    final tripsBox = await Hive.openBox<dynamic>(tripsBoxName);
    final statisticsBox = await Hive.openBox<dynamic>(statisticsBoxName);
    return HiveService(carsBox, settingsBox, tripsBox, statisticsBox);
  }
}
