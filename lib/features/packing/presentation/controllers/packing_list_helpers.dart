import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';

List<PackingItem> packingActiveItems(PackingList list) {
  return list.items.where((item) => item.deletedAt == null).toList();
}

int packingActiveItemCount(PackingList list) => packingActiveItems(list).length;

int packingPackedActiveItemCount(PackingList list) {
  return packingActiveItems(list).where((item) => item.isPacked).length;
}

List<PackingCategory> packingSortedCategoriesWithActiveItems(PackingList list) {
  final activeItems = packingActiveItems(list);
  final categoryIds =
      activeItems.map((item) => item.categoryId).toSet().toList();

  final categories =
      categoryIds
          .map((id) => _findCategory(list, id))
          .whereType<PackingCategory>()
          .toList();

  categories.sort((a, b) {
    final orderCompare = a.sortOrder.compareTo(b.sortOrder);
    if (orderCompare != 0) {
      return orderCompare;
    }

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  return categories;
}

List<PackingItem> packingSortedActiveItemsForCategory(
  PackingList list,
  String categoryId,
) {
  final items =
      packingActiveItems(
        list,
      ).where((item) => item.categoryId == categoryId).toList();

  items.sort((a, b) {
    final orderCompare = a.sortOrder.compareTo(b.sortOrder);
    if (orderCompare != 0) {
      return orderCompare;
    }

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  return items;
}

PackingCategory? _findCategory(PackingList list, String categoryId) {
  for (final category in list.customCategories) {
    if (category.id == categoryId) {
      return category;
    }
  }

  return null;
}

PackingCategory? packingCategoryById(PackingList list, String categoryId) {
  return _findCategory(list, categoryId);
}

PackingList copyPackingList(
  PackingList source, {
  String? name,
  String? description,
  bool clearDescription = false,
  List<PackingItem>? items,
  List<PackingCategory>? customCategories,
  DateTime? updatedAt,
}) {
  return PackingList(
    id: source.id,
    linkedTripId: source.linkedTripId,
    name: name ?? source.name,
    description: clearDescription ? null : (description ?? source.description),
    departureDate: source.departureDate,
    returnDate: source.returnDate,
    createdAt: source.createdAt,
    updatedAt: updatedAt ?? source.updatedAt,
    deletedAt: source.deletedAt,
    items: items ?? source.items,
    customCategories: customCategories ?? source.customCategories,
    persons: source.persons,
    locations: source.locations,
    settings: source.settings,
  );
}

PackingItem copyPackingItem(
  PackingItem source, {
  String? name,
  String? categoryId,
  int? quantity,
  String? unit,
  PackingPriority? priority,
  bool? isPacked,
  bool? needsPurchase,
  bool? isPurchased,
  String? note,
  bool clearNote = false,
  DateTime? updatedAt,
  DateTime? deletedAt,
  bool clearDeletedAt = false,
}) {
  return PackingItem(
    id: source.id,
    packingListId: source.packingListId,
    name: name ?? source.name,
    categoryId: categoryId ?? source.categoryId,
    quantity: quantity ?? source.quantity,
    unit: unit ?? source.unit,
    personId: source.personId,
    locationId: source.locationId,
    priority: priority ?? source.priority,
    isPacked: isPacked ?? source.isPacked,
    needsPurchase: needsPurchase ?? source.needsPurchase,
    isPurchased: isPurchased ?? source.isPurchased,
    note: clearNote ? null : (note ?? source.note),
    weightPerUnitGrams: source.weightPerUnitGrams,
    reminderAt: source.reminderAt,
    sortOrder: source.sortOrder,
    createdAt: source.createdAt,
    updatedAt: updatedAt ?? source.updatedAt,
    deletedAt: clearDeletedAt ? null : (deletedAt ?? source.deletedAt),
  );
}

int packingNextCategorySortOrder(PackingList list) {
  if (list.customCategories.isEmpty) {
    return 0;
  }

  return list.customCategories
          .map((category) => category.sortOrder)
          .reduce((a, b) => a > b ? a : b) +
      1;
}

int packingNextItemSortOrder(PackingList list, String categoryId) {
  final items =
      packingActiveItems(
        list,
      ).where((item) => item.categoryId == categoryId).toList();

  if (items.isEmpty) {
    return 0;
  }

  return items.map((item) => item.sortOrder).reduce((a, b) => a > b ? a : b) +
      1;
}
