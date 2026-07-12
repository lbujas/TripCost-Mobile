import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/features/packing/data/repositories/packing_list_repository_impl.dart';
import 'package:travel_cost_planner_europe/features/packing/data/sources/packing_list_local_source.dart';

import '../../packing_test_data.dart';

void main() {
  late Directory tempDir;
  late HiveService hiveService;
  late PackingListRepositoryImpl repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('packing_repository_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    hiveService = await HiveService.open();
    repository = PackingListRepositoryImpl(PackingListLocalSource(hiveService));
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

  group('PackingListRepositoryImpl', () {
    test('returns empty storage when no lists exist', () async {
      final lists = await repository.getPackingLists();

      expect(lists, isEmpty);
    });

    test('saves and retrieves a packing list by id', () async {
      final list = samplePackingList(id: 'list-1');

      await repository.savePackingList(list);

      final loaded = await repository.getPackingListById('list-1');
      expect(loaded, isNotNull);
      expect(loaded!.name, list.name);
    });

    test('updates an existing list with the same id', () async {
      final original = samplePackingList(id: 'list-1', name: 'Original');
      await repository.savePackingList(original);

      final updated = samplePackingList(
        id: 'list-1',
        name: 'Updated name',
        description: 'Updated description',
      );
      await repository.savePackingList(updated);

      final loaded = await repository.getPackingListById('list-1');
      expect(loaded!.name, 'Updated name');
      expect(loaded.description, 'Updated description');
      expect(hiveService.packingListsBox.length, 1);
    });

    test('returns all active packing lists', () async {
      await repository.savePackingList(samplePackingList(id: 'list-1'));
      await repository.savePackingList(
        samplePackingList(id: 'list-2', name: 'Second list'),
      );

      final lists = await repository.getPackingLists();

      expect(lists, hasLength(2));
    });

    test('finds lists by linkedTripId through active reads', () async {
      await repository.savePackingList(
        samplePackingList(id: 'list-1', linkedTripId: 'trip-42'),
      );
      await repository.savePackingList(
        samplePackingList(id: 'list-2', linkedTripId: 'trip-99'),
      );
      await repository.savePackingList(
        samplePackingList(id: 'list-3', linkedTripId: 'trip-42'),
      );

      final linked =
          (await repository.getPackingLists())
              .where((list) => list.linkedTripId == 'trip-42')
              .toList();

      expect(linked, hasLength(2));
      expect(linked.map((list) => list.id), containsAll(['list-1', 'list-3']));
    });

    test(
      'soft delete hides list from default reads but keeps record',
      () async {
        await repository.savePackingList(samplePackingList(id: 'list-1'));

        await repository.deletePackingListSoft('list-1');

        expect(await repository.getPackingListById('list-1'), isNull);
        expect(await repository.getPackingLists(), isEmpty);
        expect(hiveService.packingListsBox.containsKey('list-1'), isTrue);

        final raw = hiveService.packingListsBox.get('list-1') as Map;
        expect(raw['deletedAt'], isNotNull);
      },
    );

    test('restore makes a soft-deleted list active again', () async {
      await repository.savePackingList(samplePackingList(id: 'list-1'));
      await repository.deletePackingListSoft('list-1');

      await repository.restorePackingList('list-1');

      final restored = await repository.getPackingListById('list-1');
      expect(restored, isNotNull);
      expect(restored!.deletedAt, isNull);
    });

    test('preserves createdAt across updates', () async {
      final createdAt = DateTime.utc(2026, 5, 1, 9, 0);
      await repository.savePackingList(
        samplePackingList(
          id: 'list-1',
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 2));
      await repository.savePackingList(
        samplePackingList(
          id: 'list-1',
          name: 'Updated',
          createdAt: DateTime.utc(2099, 1, 1),
          updatedAt: DateTime.utc(2099, 1, 1),
        ),
      );

      final loaded = await repository.getPackingListById('list-1');
      expect(loaded!.createdAt, createdAt);
    });

    test('updates updatedAt on save', () async {
      final firstUpdatedAt = DateTime.utc(2026, 5, 1, 9, 0);
      await repository.savePackingList(
        samplePackingList(id: 'list-1', updatedAt: firstUpdatedAt),
      );

      await Future<void>.delayed(const Duration(milliseconds: 2));
      await repository.savePackingList(
        samplePackingList(
          id: 'list-1',
          name: 'Updated',
          updatedAt: firstUpdatedAt,
        ),
      );

      final loaded = await repository.getPackingListById('list-1');
      expect(loaded!.updatedAt.isAfter(firstUpdatedAt), isTrue);
    });

    test('sets timestamps on soft delete', () async {
      final createdAt = DateTime.utc(2026, 5, 1, 9, 0);
      await repository.savePackingList(
        samplePackingList(
          id: 'list-1',
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 2));
      await repository.deletePackingListSoft('list-1');

      final raw = Map<String, dynamic>.from(
        hiveService.packingListsBox.get('list-1') as Map,
      );

      final deletedAt = DateTime.parse(raw['deletedAt'] as String);
      final updatedAt = DateTime.parse(raw['updatedAt'] as String);

      expect(deletedAt.isAfter(createdAt), isTrue);
      expect(updatedAt.isAfter(createdAt), isTrue);
    });

    test('links and unlinks a trip id', () async {
      await repository.savePackingList(samplePackingList(id: 'list-1'));

      await repository.linkToTrip(listId: 'list-1', tripId: 'trip-42');

      var loaded = await repository.getPackingListById('list-1');
      expect(loaded!.linkedTripId, 'trip-42');

      await repository.unlinkFromTrip('list-1');

      loaded = await repository.getPackingListById('list-1');
      expect(loaded!.linkedTripId, isNull);
    });

    test('round-trips nested JSON through save and read', () async {
      final list = samplePackingList(
        id: 'list-nested',
        linkedTripId: 'trip-42',
      );

      await repository.savePackingList(list);

      final loaded = await repository.getPackingListById('list-nested');
      expect(loaded!.items.single.name, 'Sunscreen');
      expect(loaded.customCategories.single.name, 'Toiletries');
      expect(loaded.persons.single.name, 'Alex');
      expect(loaded.locations.single.name, 'Carry-on luggage');
      expect(loaded.settings.remindersEnabled, isTrue);
    });

    test('handles multiple independent packing lists', () async {
      await repository.savePackingList(samplePackingList(id: 'list-1'));
      await repository.savePackingList(
        samplePackingList(id: 'list-2', name: 'Winter ski'),
      );
      await repository.deletePackingListSoft('list-1');

      final active = await repository.getPackingLists();
      expect(active, hasLength(1));
      expect(active.single.id, 'list-2');
      expect(hiveService.packingListsBox.length, 2);
    });
  });
}
