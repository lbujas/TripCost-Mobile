import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/domain/repositories/car_repository.dart';
import 'package:travel_cost_planner_europe/domain/repositories/trip_repository.dart';
import 'package:travel_cost_planner_europe/features/packing/data/sources/packing_list_local_source.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/repositories/packing_list_repository.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import '../packing_test_data.dart';

void main() {
  late Directory tempDir;
  late HiveService hiveService;
  late ProviderContainer container;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('packing_providers_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    hiveService = await HiveService.open();
    container = ProviderContainer(
      overrides: [hiveServiceProvider.overrideWithValue(hiveService)],
    );
  });

  tearDown(() async {
    container.dispose();
    await hiveService.packingListsBox.clear();
    await Hive.close();
  });

  tearDownAll(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Packing providers', () {
    test('packingListLocalSourceProvider resolves', () {
      final localSource = container.read(packingListLocalSourceProvider);

      expect(localSource, isA<PackingListLocalSource>());
    });

    test('packingListRepositoryProvider resolves as domain interface', () {
      final repository = container.read(packingListRepositoryProvider);

      expect(repository, isA<PackingListRepository>());
    });

    test('resolving providers does not write packing records', () {
      expect(hiveService.packingListsBox, isEmpty);

      container.read(packingListLocalSourceProvider);
      container.read(packingListRepositoryProvider);

      expect(hiveService.packingListsBox, isEmpty);
    });

    test('repository uses the dedicated packing Hive box', () async {
      final repository = container.read(packingListRepositoryProvider);

      await repository.savePackingList(samplePackingList(id: 'list-provider'));

      expect(hiveService.packingListsBox.containsKey('list-provider'), isTrue);
      expect(hiveService.tripsBox.keys, isEmpty);
    });

    test('existing repository providers remain available', () {
      expect(container.read(carRepositoryProvider), isA<CarRepository>());
      expect(container.read(tripRepositoryProvider), isA<TripRepository>());
    });
  });
}
