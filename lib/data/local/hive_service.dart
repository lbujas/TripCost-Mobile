import 'package:hive_flutter/hive_flutter.dart';

/// Hive initialization and box access.
class HiveService {
  HiveService(
    this._carsBox,
    this._settingsBox,
    this._tripsBox,
    this._statisticsBox,
    this._packingListsBox,
    this._packingTemplatesBox,
  );

  static const String carsBoxName = 'cars_box';
  static const String settingsBoxName = 'settings_box';
  static const String tripsBoxName = 'trips_box';
  static const String statisticsBoxName = 'statistics_box';
  static const String packingListsBoxName = 'packing_lists_box';
  static const String packingTemplatesBoxName = 'packing_templates_box';

  final Box<dynamic> _carsBox;
  final Box<dynamic> _settingsBox;
  final Box<dynamic> _tripsBox;
  final Box<dynamic> _statisticsBox;
  final Box<dynamic> _packingListsBox;
  final Box<dynamic> _packingTemplatesBox;

  Box<dynamic> get carsBox => _carsBox;
  Box<dynamic> get settingsBox => _settingsBox;
  Box<dynamic> get tripsBox => _tripsBox;
  Box<dynamic> get statisticsBox => _statisticsBox;
  Box<dynamic> get packingListsBox => _packingListsBox;
  Box<dynamic> get packingTemplatesBox => _packingTemplatesBox;

  static Future<HiveService> init() async {
    await Hive.initFlutter();
    return open();
  }

  static Future<HiveService> open() async {
    final carsBox = await Hive.openBox<dynamic>(carsBoxName);
    final settingsBox = await Hive.openBox<dynamic>(settingsBoxName);
    final tripsBox = await Hive.openBox<dynamic>(tripsBoxName);
    final statisticsBox = await Hive.openBox<dynamic>(statisticsBoxName);
    final packingListsBox = await Hive.openBox<dynamic>(packingListsBoxName);
    final packingTemplatesBox = await Hive.openBox<dynamic>(
      packingTemplatesBoxName,
    );
    return HiveService(
      carsBox,
      settingsBox,
      tripsBox,
      statisticsBox,
      packingListsBox,
      packingTemplatesBox,
    );
  }
}
