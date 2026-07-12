import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_lists_controller.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import '../../packing_test_data.dart';
import '../../fake_packing_list_repository.dart';

void main() {
  group('PackingListsController', () {
    late FakePackingListRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakePackingListRepository();
      container = ProviderContainer(
        overrides: [
          packingListRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads empty list', () async {
      final lists = await container.read(packingListsControllerProvider.future);

      expect(lists, isEmpty);
    });

    test('loads saved lists', () async {
      repository.lists.add(samplePackingList(id: 'list-1'));

      final lists = await container.read(packingListsControllerProvider.future);

      expect(lists, hasLength(1));
      expect(lists.single.id, 'list-1');
    });

    test('sortedByUpdatedAt sorts lists descending', () {
      final older = samplePackingList(
        id: 'older',
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final newer = samplePackingList(
        id: 'newer',
        updatedAt: DateTime.utc(2026, 6, 1),
      );

      final sorted = PackingListsController.sortedByUpdatedAt([older, newer]);

      expect(sorted.map((list) => list.id).toList(), ['newer', 'older']);
    });

    test('creates a new list', () async {
      await container.read(packingListsControllerProvider.future);

      final created = await container
          .read(packingListsControllerProvider.notifier)
          .createPackingList(name: 'Beach trip', description: 'Summer');

      expect(created, isTrue);
      expect(repository.saveCallCount, 1);
      expect(repository.lastSaved?.name, 'Beach trip');
      expect(repository.lastSaved?.description, 'Summer');
      expect(repository.lastSaved?.linkedTripId, isNull);
      expect(repository.lastSaved?.items, isEmpty);

      final lists = container.read(packingListsControllerProvider).value!;
      expect(lists, hasLength(1));
      expect(lists.single.name, 'Beach trip');
    });

    test('trims name and description', () async {
      await container.read(packingListsControllerProvider.future);

      await container
          .read(packingListsControllerProvider.notifier)
          .createPackingList(name: '  Beach trip  ', description: '  Summer  ');

      expect(repository.lastSaved?.name, 'Beach trip');
      expect(repository.lastSaved?.description, 'Summer');
    });

    test('rejects empty name', () async {
      await container.read(packingListsControllerProvider.future);

      final created = await container
          .read(packingListsControllerProvider.notifier)
          .createPackingList(name: '   ');

      expect(created, isFalse);
      expect(repository.saveCallCount, 0);
    });

    test('refreshes after creation', () async {
      await container.read(packingListsControllerProvider.future);

      await container
          .read(packingListsControllerProvider.notifier)
          .createPackingList(name: 'Camping');

      final state = container.read(packingListsControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value, hasLength(1));
    });

    test('handles repository errors', () async {
      repository.loadError = StateError('load failed');

      await expectLater(
        container.read(packingListsControllerProvider.future),
        throwsA(isA<StateError>()),
      );
    });
  });
}
