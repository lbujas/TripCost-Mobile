import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_checkbox_mode.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_options.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_scope.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_list_export_data_builder.dart';

import '../../packing_test_data.dart';

PackingList _exportTestList() {
  final timestamp = DateTime.utc(2026, 6, 1, 10, 0);
  return PackingList(
    id: 'list-export',
    name: 'Summer trip',
    createdAt: timestamp,
    updatedAt: timestamp,
    customCategories: [
      PackingCategory(
        id: 'cat-clothes',
        name: 'Clothes',
        sortOrder: 0,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      PackingCategory(
        id: 'cat-shop',
        name: 'Shopping',
        sortOrder: 1,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ],
    items: [
      PackingItem(
        id: 'item-shirt',
        packingListId: 'list-export',
        name: 'Shirt',
        categoryId: 'cat-clothes',
        isPacked: true,
        sortOrder: 0,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      PackingItem(
        id: 'item-pants',
        packingListId: 'list-export',
        name: 'Pants',
        categoryId: 'cat-clothes',
        sortOrder: 1,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      PackingItem(
        id: 'item-snacks',
        packingListId: 'list-export',
        name: 'Snacks',
        categoryId: 'cat-shop',
        quantity: 3,
        unit: 'pack',
        needsPurchase: true,
        isPurchased: true,
        sortOrder: 0,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      PackingItem(
        id: 'item-water',
        packingListId: 'list-export',
        name: 'Water',
        categoryId: 'cat-shop',
        needsPurchase: true,
        sortOrder: 1,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
      PackingItem(
        id: 'item-deleted',
        packingListId: 'list-export',
        name: 'Deleted item',
        categoryId: 'cat-clothes',
        deletedAt: timestamp,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    ],
  );
}

void main() {
  const builder = PackingListExportDataBuilder();

  group('PackingListExportDataBuilder', () {
    test('full list includes all active items', () {
      final data = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(scope: PackingPdfScope.fullList),
      );

      expect(data.totalItems, 4);
      expect(data.categories, hasLength(2));
    });

    test('deleted items excluded', () {
      final data = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(),
      );

      final names =
          data.categories
              .expand((category) => category.items)
              .map((item) => item.name)
              .toList();
      expect(names, isNot(contains('Deleted item')));
    });

    test('unpacked scope', () {
      final data = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(scope: PackingPdfScope.unpackedOnly),
      );

      expect(data.totalItems, 3);
      expect(
        data.categories.expand((c) => c.items).map((item) => item.name),
        containsAll(['Pants', 'Water', 'Snacks']),
      );
    });

    test('packed scope', () {
      final data = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(scope: PackingPdfScope.packedItems),
      );

      expect(data.totalItems, 1);
      expect(data.categories.single.items.single.name, 'Shirt');
    });

    test('shopping scope', () {
      final data = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(scope: PackingPdfScope.shoppingList),
      );

      expect(data.totalItems, 2);
    });

    test('purchased shopping item inclusion and exclusion', () {
      final included = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(
          scope: PackingPdfScope.shoppingList,
          includePurchasedShoppingItems: true,
        ),
      );
      final excluded = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(
          scope: PackingPdfScope.shoppingList,
          includePurchasedShoppingItems: false,
        ),
      );

      expect(included.totalItems, 2);
      expect(excluded.totalItems, 1);
      expect(excluded.categories.single.items.single.name, 'Water');
    });

    test('selected category scope', () {
      final data = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(
          scope: PackingPdfScope.selectedCategory,
          selectedCategoryId: 'cat-clothes',
        ),
      );

      expect(data.totalItems, 2);
      expect(data.categories.single.name, 'Clothes');
    });

    test('quantity greater than one still counts as one checklist row', () {
      final data = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(scope: PackingPdfScope.shoppingList),
      );

      final snacks = data.categories
          .expand((category) => category.items)
          .firstWhere((item) => item.name == 'Snacks');
      expect(snacks.quantity, 3);
      expect(data.totalItems, 2);
    });

    test('correct packed and purchased totals', () {
      final packedData = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(
          scope: PackingPdfScope.fullList,
          checkboxMode: PackingCheckboxMode.currentState,
        ),
      );
      final shoppingData = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(
          scope: PackingPdfScope.shoppingList,
          checkboxMode: PackingCheckboxMode.currentState,
        ),
      );

      expect(packedData.checkedCount, 1);
      expect(shoppingData.checkedCount, 1);
    });

    test('deterministic category and item ordering', () {
      final data = builder.build(
        list: _exportTestList(),
        options: const PackingPdfOptions(),
      );

      expect(data.categories.map((category) => category.name), [
        'Clothes',
        'Shopping',
      ]);
      expect(data.categories.first.items.map((item) => item.name), [
        'Shirt',
        'Pants',
      ]);
    });

    test('empty result handling', () {
      final data = builder.build(
        list: samplePackingList(),
        options: const PackingPdfOptions(scope: PackingPdfScope.packedItems),
      );

      expect(data.isEmpty, isTrue);
      expect(data.totalItems, 0);
    });
  });
}
