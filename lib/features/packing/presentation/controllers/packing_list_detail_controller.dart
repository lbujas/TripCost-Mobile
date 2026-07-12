import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_helpers.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_lists_controller.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

final packingListDetailControllerProvider = AsyncNotifierProvider.family<
  PackingListDetailController,
  PackingList,
  String
>(PackingListDetailController.new);

class PackingListDetailController
    extends FamilyAsyncNotifier<PackingList, String> {
  var _generatedIdCounter = 0;

  String _newEntityId(String prefix, DateTime now) {
    _generatedIdCounter += 1;
    return '${prefix}_${now.microsecondsSinceEpoch}_$_generatedIdCounter';
  }

  @override
  Future<PackingList> build(String listId) async {
    return _loadById(listId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadById(arg));
  }

  Future<void> updateListMetadata({
    required String name,
    String? description,
  }) async {
    final trimmedName = name.trim();
    final trimmedDescription = description?.trim();

    if (trimmedName.isEmpty) {
      throw StateError('name');
    }

    final current = state.requireValue;
    await _save(
      copyPackingList(
        current,
        name: trimmedName,
        description:
            trimmedDescription == null || trimmedDescription.isEmpty
                ? null
                : trimmedDescription,
        clearDescription:
            trimmedDescription == null || trimmedDescription.isEmpty,
      ),
    );
  }

  Future<void> addItem({
    required String name,
    String? categoryId,
    String? newCategoryName,
    required int quantity,
    required String unit,
    PackingPriority priority = PackingPriority.normal,
    bool needsPurchase = false,
    String? note,
  }) async {
    final trimmedName = name.trim();
    final trimmedUnit = unit.trim();
    final trimmedCategoryName = newCategoryName?.trim();
    final trimmedNote = note?.trim();

    if (trimmedName.isEmpty) {
      throw StateError('name');
    }
    if (quantity <= 0) {
      throw StateError('quantity');
    }
    if (trimmedUnit.isEmpty) {
      throw StateError('unit');
    }

    final current = state.requireValue;
    final now = DateTime.now().toUtc();
    final resolvedCategoryId = _resolveCategoryId(
      current: current,
      categoryId: categoryId,
      newCategoryName: trimmedCategoryName,
      now: now,
    );

    if (resolvedCategoryId == null) {
      throw StateError('category');
    }

    final categories = [...current.customCategories];
    if (trimmedCategoryName != null && trimmedCategoryName.isNotEmpty) {
      categories.add(
        PackingCategory(
          id: resolvedCategoryId,
          name: trimmedCategoryName,
          sortOrder: packingNextCategorySortOrder(current),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    final item = PackingItem(
      id: _newEntityId('packing_item', now),
      packingListId: current.id,
      name: trimmedName,
      categoryId: resolvedCategoryId,
      quantity: quantity,
      unit: trimmedUnit,
      priority: priority,
      needsPurchase: needsPurchase,
      note: trimmedNote == null || trimmedNote.isEmpty ? null : trimmedNote,
      sortOrder: packingNextItemSortOrder(current, resolvedCategoryId),
      createdAt: now,
      updatedAt: now,
    );

    await _save(
      copyPackingList(
        current,
        items: [...current.items, item],
        customCategories: categories,
      ),
    );
  }

  Future<void> updateItem({
    required String itemId,
    required String name,
    String? categoryId,
    String? newCategoryName,
    required int quantity,
    required String unit,
    PackingPriority priority = PackingPriority.normal,
    bool needsPurchase = false,
    String? note,
  }) async {
    final trimmedName = name.trim();
    final trimmedUnit = unit.trim();
    final trimmedCategoryName = newCategoryName?.trim();
    final trimmedNote = note?.trim();

    if (trimmedName.isEmpty) {
      throw StateError('name');
    }
    if (quantity <= 0) {
      throw StateError('quantity');
    }
    if (trimmedUnit.isEmpty) {
      throw StateError('unit');
    }

    final current = state.requireValue;
    final existing = _findActiveItem(current, itemId);
    if (existing == null) {
      throw StateError('Item not found: $itemId');
    }

    final now = DateTime.now().toUtc();
    final resolvedCategoryId = _resolveCategoryId(
      current: current,
      categoryId: categoryId ?? existing.categoryId,
      newCategoryName: trimmedCategoryName,
      now: now,
    );

    if (resolvedCategoryId == null) {
      throw StateError('category');
    }

    var categories = [...current.customCategories];
    if (trimmedCategoryName != null && trimmedCategoryName.isNotEmpty) {
      categories.add(
        PackingCategory(
          id: resolvedCategoryId,
          name: trimmedCategoryName,
          sortOrder: packingNextCategorySortOrder(current),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    final items =
        current.items.map((item) {
          if (item.id != itemId) {
            return item;
          }

          return copyPackingItem(
            item,
            name: trimmedName,
            categoryId: resolvedCategoryId,
            quantity: quantity,
            unit: trimmedUnit,
            priority: priority,
            needsPurchase: needsPurchase,
            note: trimmedNote,
            clearNote: trimmedNote == null || trimmedNote.isEmpty,
            updatedAt: now,
          );
        }).toList();

    await _save(
      copyPackingList(current, items: items, customCategories: categories),
    );
  }

  Future<void> togglePacked(String itemId) async {
    await _updateItemFlag(
      itemId,
      (item) => copyPackingItem(item, isPacked: !item.isPacked),
    );
  }

  Future<void> toggleNeedsPurchase(String itemId) async {
    await _updateItemFlag(
      itemId,
      (item) => copyPackingItem(item, needsPurchase: !item.needsPurchase),
    );
  }

  Future<void> togglePurchased(String itemId) async {
    await _updateItemFlag(
      itemId,
      (item) => copyPackingItem(item, isPurchased: !item.isPurchased),
    );
  }

  Future<void> softDeleteItem(String itemId) async {
    final current = state.requireValue;
    final now = DateTime.now().toUtc();
    final items =
        current.items.map((item) {
          if (item.id != itemId || item.deletedAt != null) {
            return item;
          }

          return copyPackingItem(item, deletedAt: now, updatedAt: now);
        }).toList();

    await _save(copyPackingList(current, items: items));
  }

  Future<void> _updateItemFlag(
    String itemId,
    PackingItem Function(PackingItem item) transform,
  ) async {
    final current = state.requireValue;
    final now = DateTime.now().toUtc();
    final items =
        current.items.map((item) {
          if (item.id != itemId || item.deletedAt != null) {
            return item;
          }

          return transform(copyPackingItem(item, updatedAt: now));
        }).toList();

    await _save(copyPackingList(current, items: items));
  }

  Future<void> _save(PackingList updated) async {
    state = await AsyncValue.guard(() async {
      await ref.read(packingListRepositoryProvider).savePackingList(updated);
      ref.invalidate(packingListsControllerProvider);
      return _loadById(updated.id);
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<PackingList> _loadById(String listId) async {
    final list = await ref
        .read(packingListRepositoryProvider)
        .getPackingListById(listId);

    if (list == null) {
      throw StateError('Packing list not found: $listId');
    }

    return list;
  }

  String? _resolveCategoryId({
    required PackingList current,
    required String? categoryId,
    required String? newCategoryName,
    required DateTime now,
  }) {
    if (newCategoryName != null && newCategoryName.isNotEmpty) {
      return _newEntityId('packing_cat', now);
    }

    if (categoryId == null || categoryId.isEmpty) {
      return null;
    }

    if (packingCategoryById(current, categoryId) == null) {
      return null;
    }

    return categoryId;
  }

  PackingItem? _findActiveItem(PackingList list, String itemId) {
    for (final item in list.items) {
      if (item.id == itemId && item.deletedAt == null) {
        return item;
      }
    }

    return null;
  }
}
