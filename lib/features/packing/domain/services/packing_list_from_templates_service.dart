import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list_settings.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_template_merge_service.dart';

typedef PackingIdGenerator = String Function(String prefix);
typedef PackingLocalizationResolver = String Function(String key);

/// Builds a new [PackingList] aggregate from selected templates.
class PackingListFromTemplatesService {
  const PackingListFromTemplatesService(this._mergeService);

  final PackingTemplateMergeService _mergeService;

  PackingList create({
    required List<PackingTemplate> templates,
    required String packingListId,
    required String listName,
    String? description,
    String? linkedTripId,
    DateTime? departureDate,
    DateTime? returnDate,
    required DateTime createdAt,
    required PackingIdGenerator idGenerator,
    required PackingLocalizationResolver localizationResolver,
  }) {
    final mergedItems = _mergeService.mergeTemplates(templates);
    final categoryIds = <String, String>{};
    final categories = <PackingCategory>[];
    final items = <PackingItem>[];

    for (final templateItem in mergedItems) {
      final categoryKey = _categoryIdentityKey(templateItem);
      final categoryId = categoryIds.putIfAbsent(categoryKey, () {
        final id = idGenerator('packing_cat');
        categories.add(
          PackingCategory(
            id: id,
            name: _resolveCategoryName(templateItem, localizationResolver),
            sortOrder: categories.length,
            isSystem: templateItem.categoryKey != null,
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        );
        return id;
      });

      items.add(
        PackingItem(
          id: idGenerator('packing_item'),
          packingListId: packingListId,
          name: _resolveItemName(templateItem, localizationResolver),
          categoryId: categoryId,
          quantity: templateItem.quantity,
          unit: localizationResolver(templateItem.unitKey),
          priority: templateItem.priority,
          needsPurchase: templateItem.needsPurchase,
          note: _resolveNote(templateItem, localizationResolver),
          sortOrder: templateItem.sortOrder,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
    }

    return PackingList(
      id: packingListId,
      linkedTripId: linkedTripId,
      name: listName.trim(),
      description:
          description == null || description.trim().isEmpty
              ? null
              : description.trim(),
      departureDate: departureDate,
      returnDate: returnDate,
      createdAt: createdAt,
      updatedAt: createdAt,
      items: items,
      customCategories: categories,
      settings: const PackingListSettings(),
    );
  }

  String _categoryIdentityKey(PackingTemplateItem item) {
    if (item.categoryKey != null) {
      return 'key:${item.categoryKey}';
    }

    return 'name:${normalizeText(item.customCategoryName ?? '')}';
  }

  String _resolveItemName(
    PackingTemplateItem item,
    PackingLocalizationResolver localizationResolver,
  ) {
    if (item.nameKey != null) {
      return localizationResolver(item.nameKey!);
    }

    return item.customName!.trim();
  }

  String _resolveCategoryName(
    PackingTemplateItem item,
    PackingLocalizationResolver localizationResolver,
  ) {
    if (item.categoryKey != null) {
      return localizationResolver(item.categoryKey!);
    }

    return item.customCategoryName!.trim();
  }

  String? _resolveNote(
    PackingTemplateItem item,
    PackingLocalizationResolver localizationResolver,
  ) {
    if (item.noteKey != null) {
      return localizationResolver(item.noteKey!);
    }

    final customNote = item.customNote?.trim();
    if (customNote == null || customNote.isEmpty) {
      return null;
    }

    return customNote;
  }
}
