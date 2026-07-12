import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template_item.dart';

/// Combines items from multiple templates with duplicate detection.
class PackingTemplateMergeService {
  const PackingTemplateMergeService();

  List<PackingTemplateItem> mergeTemplates(List<PackingTemplate> templates) {
    final merged = <String, PackingTemplateItem>{};
    final order = <String>[];

    for (final template in templates) {
      for (final item in template.items) {
        final key = _duplicateKey(item);
        final existing = merged[key];

        if (existing == null) {
          merged[key] = item;
          order.add(key);
          continue;
        }

        merged[key] = _mergeItems(existing, item);
      }
    }

    final result = order.map((key) => merged[key]!).toList(growable: false)
      ..sort(_compareItems);

    return List.unmodifiable(result);
  }

  PackingTemplateItem _mergeItems(
    PackingTemplateItem existing,
    PackingTemplateItem incoming,
  ) {
    return PackingTemplateItem(
      id: existing.id,
      nameKey: existing.nameKey ?? incoming.nameKey,
      customName: existing.customName ?? incoming.customName,
      categoryKey: existing.categoryKey ?? incoming.categoryKey,
      customCategoryName:
          existing.customCategoryName ?? incoming.customCategoryName,
      quantity:
          existing.quantity > incoming.quantity
              ? existing.quantity
              : incoming.quantity,
      unitKey: existing.unitKey,
      priority: _higherPriority(existing.priority, incoming.priority),
      needsPurchase: existing.needsPurchase || incoming.needsPurchase,
      noteKey: existing.noteKey ?? incoming.noteKey,
      customNote: existing.customNote ?? incoming.customNote,
      sortOrder:
          existing.sortOrder <= incoming.sortOrder
              ? existing.sortOrder
              : incoming.sortOrder,
    );
  }

  int _compareItems(PackingTemplateItem a, PackingTemplateItem b) {
    final orderCompare = a.sortOrder.compareTo(b.sortOrder);
    if (orderCompare != 0) {
      return orderCompare;
    }

    return _itemSortLabel(a).compareTo(_itemSortLabel(b));
  }

  String _itemSortLabel(PackingTemplateItem item) {
    return item.nameKey ?? normalizeText(item.customName ?? item.id);
  }

  String _duplicateKey(PackingTemplateItem item) {
    final itemPart =
        item.nameKey != null
            ? 'key:${item.nameKey}'
            : 'name:${normalizeText(item.customName ?? '')}';
    final categoryPart =
        item.categoryKey != null
            ? 'key:${item.categoryKey}'
            : 'name:${normalizeText(item.customCategoryName ?? '')}';

    return '$categoryPart|$itemPart';
  }

  PackingPriority _higherPriority(PackingPriority left, PackingPriority right) {
    return _priorityRank(left) >= _priorityRank(right) ? left : right;
  }

  int _priorityRank(PackingPriority priority) {
    switch (priority) {
      case PackingPriority.normal:
        return 0;
      case PackingPriority.important:
        return 1;
      case PackingPriority.critical:
        return 2;
    }
  }
}

String normalizeText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
