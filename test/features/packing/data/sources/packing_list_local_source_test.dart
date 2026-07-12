import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/features/packing/data/sources/packing_list_local_source.dart';

import '../../packing_test_data.dart';

void main() {
  late Directory tempDir;
  late HiveService hiveService;
  late PackingListLocalSource localSource;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'packing_local_source_test_',
    );
    Hive.init(tempDir.path);
  });

  setUp(() async {
    hiveService = await HiveService.open();
    localSource = PackingListLocalSource(hiveService);
  });

  tearDown(() async {
    await hiveService.packingListsBox.clear();
    await Hive.close();
  });

  tearDownAll(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PackingListLocalSource', () {
    test('returns empty storage when box is empty', () async {
      final lists = await localSource.getAll(includeDeleted: false);

      expect(lists, isEmpty);
    });

    test('saves and reads a packing list by id', () async {
      final list = samplePackingList(id: 'list-1');

      await localSource.put(list);

      final loaded = await localSource.getById('list-1');
      expect(loaded, isNotNull);
      expect(loaded!.id, 'list-1');
      expect(loaded.name, list.name);
    });

    test('overwrites an existing record with the same id', () async {
      final original = samplePackingList(id: 'list-1', name: 'Original');
      final updated = samplePackingList(
        id: 'list-1',
        name: 'Updated',
        updatedAt: DateTime.utc(2026, 6, 3),
      );

      await localSource.put(original);
      await localSource.put(updated);

      final loaded = await localSource.getById('list-1');
      expect(loaded!.name, 'Updated');
      expect(hiveService.packingListsBox.length, 1);
    });

    test('returns all active records', () async {
      await localSource.put(samplePackingList(id: 'list-1'));
      await localSource.put(samplePackingList(id: 'list-2', name: 'Second'));

      final lists = await localSource.getAll(includeDeleted: false);

      expect(lists, hasLength(2));
      expect(lists.map((list) => list.id), containsAll(['list-1', 'list-2']));
    });

    test('excludes soft-deleted records by default', () async {
      await localSource.put(
        samplePackingList(id: 'list-active', deletedAt: null),
      );
      await localSource.put(
        samplePackingList(
          id: 'list-deleted',
          deletedAt: DateTime.utc(2026, 8, 1),
        ),
      );

      final active = await localSource.getAll(includeDeleted: false);
      final all = await localSource.getAll(includeDeleted: true);

      expect(active, hasLength(1));
      expect(active.single.id, 'list-active');
      expect(all, hasLength(2));
    });

    test('skips invalid records during read', () async {
      await hiveService.packingListsBox.put(
        'valid-list',
        samplePackingList(id: 'valid-list').toJson(),
      );
      await hiveService.packingListsBox.put('invalid-list', 'not-a-map');
      await hiveService.packingListsBox.put('corrupt-list', {
        'id': 'corrupt-list',
      });

      final lists = await localSource.getAll(includeDeleted: true);

      expect(lists, hasLength(1));
      expect(lists.single.id, 'valid-list');
    });

    test('round-trips JSON for nested aggregate fields', () async {
      final list = samplePackingList(
        id: 'list-nested',
        linkedTripId: 'trip-42',
      );

      await localSource.put(list);

      final loaded = await localSource.getById('list-nested');
      expect(loaded!.linkedTripId, 'trip-42');
      expect(loaded.items, hasLength(1));
      expect(loaded.customCategories, hasLength(1));
      expect(loaded.persons, hasLength(1));
      expect(loaded.locations, hasLength(1));
      expect(loaded.settings.defaultSortMode.name, isNotEmpty);
    });

    test('stores each list under its id key', () async {
      await localSource.put(samplePackingList(id: 'list-a'));
      await localSource.put(samplePackingList(id: 'list-b', name: 'B'));

      expect(hiveService.packingListsBox.containsKey('list-a'), isTrue);
      expect(hiveService.packingListsBox.containsKey('list-b'), isTrue);
      expect(hiveService.packingListsBox.get('list-a'), isA<Map>());
    });
  });
}
