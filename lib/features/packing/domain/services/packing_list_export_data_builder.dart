import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_checkbox_mode.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list_export_data.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_options.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_scope.dart';

/// Organizes [PackingList] domain data for PDF export without rendering.
class PackingListExportDataBuilder {
  const PackingListExportDataBuilder();

  PackingListExportData build({
    required PackingList list,
    required PackingPdfOptions options,
    DateTime? generatedAt,
  }) {
    final activeItems = _filterItems(list, options);
    final activeItemIds = activeItems.map((item) => item.id).toSet();
    final categories = _sortedCategoriesWithActiveItems(list, activeItemIds);

    final categoryGroups = <PackingExportCategoryGroup>[];
    var totalItems = 0;
    var checkedCount = 0;

    for (final category in categories) {
      final categoryItems =
          _sortedItemsForCategory(
            list,
            category.id,
          ).where((item) => activeItemIds.contains(item.id)).toList();

      if (categoryItems.isEmpty) {
        continue;
      }

      final rows =
          categoryItems.map((item) {
            final isChecked = _resolveCheckedState(item, options);
            if (isChecked) {
              checkedCount++;
            }
            totalItems++;

            return PackingExportItemRow(
              name: item.name,
              quantity: item.quantity,
              unit: item.unit,
              note: item.note,
              priority: item.priority,
              needsPurchase: item.needsPurchase,
              isPurchased: item.isPurchased,
              isChecked: isChecked,
            );
          }).toList();

      categoryGroups.add(
        PackingExportCategoryGroup(
          id: category.id,
          name: category.name,
          items: rows,
        ),
      );
    }

    return PackingListExportData(
      listName: list.name,
      description: list.description,
      departureDate: list.departureDate,
      returnDate: list.returnDate,
      generatedAt: generatedAt ?? DateTime.now(),
      totalItems: totalItems,
      checkedCount: checkedCount,
      scope: options.scope,
      categories: categoryGroups,
    );
  }

  List<PackingItem> _activeItems(PackingList list) {
    return list.items.where((item) => item.deletedAt == null).toList();
  }

  List<PackingItem> _filterItems(PackingList list, PackingPdfOptions options) {
    return _activeItems(
      list,
    ).where((item) => _matchesScope(item, options)).toList();
  }

  bool _matchesScope(PackingItem item, PackingPdfOptions options) {
    switch (options.scope) {
      case PackingPdfScope.fullList:
        return true;
      case PackingPdfScope.unpackedOnly:
        return !item.isPacked;
      case PackingPdfScope.shoppingList:
        if (!item.needsPurchase) {
          return false;
        }
        if (!options.includePurchasedShoppingItems && item.isPurchased) {
          return false;
        }
        return true;
      case PackingPdfScope.packedItems:
        return item.isPacked;
      case PackingPdfScope.selectedCategory:
        return item.categoryId == options.selectedCategoryId;
    }
  }

  bool _resolveCheckedState(PackingItem item, PackingPdfOptions options) {
    if (options.checkboxMode == PackingCheckboxMode.empty) {
      return false;
    }

    if (options.scope == PackingPdfScope.shoppingList) {
      return item.isPurchased;
    }

    return item.isPacked;
  }

  List<PackingCategory> _sortedCategoriesWithActiveItems(
    PackingList list,
    Set<String> activeItemIds,
  ) {
    final categoryIds =
        _activeItems(list)
            .where((item) => activeItemIds.contains(item.id))
            .map((item) => item.categoryId)
            .toSet()
            .toList();

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

  List<PackingItem> _sortedItemsForCategory(
    PackingList list,
    String categoryId,
  ) {
    final items =
        _activeItems(
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
}
