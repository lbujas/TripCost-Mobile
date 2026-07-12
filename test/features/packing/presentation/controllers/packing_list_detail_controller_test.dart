import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_detail_controller.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_helpers.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import '../../fake_packing_list_repository.dart';
import '../../packing_test_data.dart';

PackingList _emptyList({String id = 'list-1'}) {
  final timestamp = DateTime.utc(2026, 6, 1, 10, 0);
  return PackingList(
    id: id,
    name: 'Weekend trip',
    description: 'Camping',
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

void main() {
  group('PackingListDetailController', () {
    late FakePackingListRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakePackingListRepository(lists: [_emptyList()]);
      container = ProviderContainer(
        overrides: [
          packingListRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads existing list', () async {
      final list = await container.read(
        packingListDetailControllerProvider('list-1').future,
      );

      expect(list.id, 'list-1');
      expect(list.name, 'Weekend trip');
    });

    test('throws for missing list', () async {
      await expectLater(
        container.read(packingListDetailControllerProvider('missing').future),
        throwsA(isA<StateError>()),
      );
    });

    test('adds category and item', () async {
      final notifier = container.read(
        packingListDetailControllerProvider('list-1').notifier,
      );
      await container.read(
        packingListDetailControllerProvider('list-1').future,
      );

      await notifier.addItem(
        name: 'Toothbrush',
        newCategoryName: 'Toiletries',
        quantity: 1,
        unit: 'piece',
      );

      final list =
          container.read(packingListDetailControllerProvider('list-1')).value!;
      expect(list.customCategories, hasLength(1));
      expect(list.customCategories.single.name, 'Toiletries');
      expect(packingActiveItems(list), hasLength(1));
      expect(packingActiveItems(list).single.name, 'Toothbrush');
    });

    test('adds item to existing category', () async {
      final notifier = container.read(
        packingListDetailControllerProvider('list-1').notifier,
      );
      await container.read(
        packingListDetailControllerProvider('list-1').future,
      );

      await notifier.addItem(
        name: 'Soap',
        newCategoryName: 'Toiletries',
        quantity: 1,
        unit: 'piece',
      );
      await notifier.addItem(
        name: 'Towel',
        categoryId: repository.lastSaved!.customCategories.single.id,
        quantity: 2,
        unit: 'piece',
      );

      final list =
          container.read(packingListDetailControllerProvider('list-1')).value!;
      expect(packingActiveItems(list), hasLength(2));
      expect(list.customCategories, hasLength(1));
    });

    test('edits item and preserves id and createdAt', () async {
      final notifier = container.read(
        packingListDetailControllerProvider('list-1').notifier,
      );
      await container.read(
        packingListDetailControllerProvider('list-1').future,
      );

      await notifier.addItem(
        name: 'Sunscreen',
        newCategoryName: 'Toiletries',
        quantity: 1,
        unit: 'bottle',
        needsPurchase: true,
      );
      await notifier.togglePurchased(
        packingActiveItems(
          container.read(packingListDetailControllerProvider('list-1')).value!,
        ).single.id,
      );

      final original =
          packingActiveItems(
            container
                .read(packingListDetailControllerProvider('list-1'))
                .value!,
          ).single;

      await notifier.updateItem(
        itemId: original.id,
        name: ' SPF 50 Sunscreen ',
        categoryId: original.categoryId,
        quantity: 2,
        unit: 'bottle',
        needsPurchase: true,
        note: 'Waterproof',
      );

      final updated =
          packingActiveItems(
            container
                .read(packingListDetailControllerProvider('list-1'))
                .value!,
          ).single;

      expect(updated.id, original.id);
      expect(updated.createdAt, original.createdAt);
      expect(updated.name, 'SPF 50 Sunscreen');
      expect(updated.quantity, 2);
      expect(updated.note, 'Waterproof');
      expect(updated.isPurchased, isTrue);
    });

    test('toggles packed independently from purchased', () async {
      final notifier = container.read(
        packingListDetailControllerProvider('list-1').notifier,
      );
      await container.read(
        packingListDetailControllerProvider('list-1').future,
      );

      await notifier.addItem(
        name: 'Adapter',
        newCategoryName: 'Electronics',
        quantity: 1,
        unit: 'piece',
        needsPurchase: true,
      );

      final itemId =
          packingActiveItems(
            container
                .read(packingListDetailControllerProvider('list-1'))
                .value!,
          ).single.id;

      await notifier.togglePurchased(itemId);
      await notifier.togglePacked(itemId);

      var item =
          packingActiveItems(
            container
                .read(packingListDetailControllerProvider('list-1'))
                .value!,
          ).single;
      expect(item.isPurchased, isTrue);
      expect(item.isPacked, isTrue);

      await notifier.togglePacked(itemId);
      item =
          packingActiveItems(
            container
                .read(packingListDetailControllerProvider('list-1'))
                .value!,
          ).single;
      expect(item.isPurchased, isTrue);
      expect(item.isPacked, isFalse);
    });

    test('toggles needs purchase', () async {
      final notifier = container.read(
        packingListDetailControllerProvider('list-1').notifier,
      );
      await container.read(
        packingListDetailControllerProvider('list-1').future,
      );

      await notifier.addItem(
        name: 'Batteries',
        newCategoryName: 'Electronics',
        quantity: 4,
        unit: 'piece',
      );

      final itemId =
          packingActiveItems(
            container
                .read(packingListDetailControllerProvider('list-1'))
                .value!,
          ).single.id;

      await notifier.toggleNeedsPurchase(itemId);

      final item =
          packingActiveItems(
            container
                .read(packingListDetailControllerProvider('list-1'))
                .value!,
          ).single;
      expect(item.needsPurchase, isTrue);
    });

    test('soft-deletes item and excludes it from progress', () async {
      final notifier = container.read(
        packingListDetailControllerProvider('list-1').notifier,
      );
      await container.read(
        packingListDetailControllerProvider('list-1').future,
      );

      await notifier.addItem(
        name: 'Shirt',
        newCategoryName: 'Clothes',
        quantity: 1,
        unit: 'piece',
      );
      await notifier.addItem(
        name: 'Pants',
        categoryId: repository.lastSaved!.customCategories.single.id,
        quantity: 1,
        unit: 'piece',
      );

      final itemId =
          packingActiveItems(
            container
                .read(packingListDetailControllerProvider('list-1'))
                .value!,
          ).first.id;

      await notifier.togglePacked(itemId);
      await notifier.softDeleteItem(itemId);

      final list =
          container.read(packingListDetailControllerProvider('list-1')).value!;
      expect(packingActiveItemCount(list), 1);
      expect(packingPackedActiveItemCount(list), 0);
      expect(list.items.where((item) => item.deletedAt != null), hasLength(1));
    });

    test('updates list name and description', () async {
      final notifier = container.read(
        packingListDetailControllerProvider('list-1').notifier,
      );
      await container.read(
        packingListDetailControllerProvider('list-1').future,
      );

      await notifier.updateListMetadata(
        name: '  Updated trip  ',
        description: '  New notes  ',
      );

      final list =
          container.read(packingListDetailControllerProvider('list-1')).value!;
      expect(list.name, 'Updated trip');
      expect(list.description, 'New notes');
      expect(list.createdAt, DateTime.utc(2026, 6, 1, 10, 0));
    });

    test('handles persistence failure', () async {
      repository.saveError = StateError('save failed');
      final notifier = container.read(
        packingListDetailControllerProvider('list-1').notifier,
      );
      await container.read(
        packingListDetailControllerProvider('list-1').future,
      );

      await expectLater(
        notifier.addItem(
          name: 'Map',
          newCategoryName: 'Documents',
          quantity: 1,
          unit: 'piece',
        ),
        throwsA(isA<StateError>()),
      );

      expect(
        container.read(packingListDetailControllerProvider('list-1')).hasError,
        isTrue,
      );
    });

    test('loads nested sample list from repository', () async {
      repository.lists = [samplePackingList(id: 'list-nested')];

      final list = await container.read(
        packingListDetailControllerProvider('list-nested').future,
      );

      expect(packingActiveItemCount(list), 1);
      expect(list.customCategories, hasLength(1));
    });
  });
}
