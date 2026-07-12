import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template_item.dart';

PackingTemplate sampleUserTemplate({
  String id = 'user_tpl_1',
  String name = 'Weekend camping',
  String? description,
  List<PackingTemplateItem>? items,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
}) {
  final timestamp = createdAt ?? DateTime.utc(2026, 6, 10, 12);
  return PackingTemplate(
    id: id,
    customName: name,
    customDescription: description,
    isSystem: false,
    items:
        items ??
        [
          PackingTemplateItem(
            id: 'user_item_1',
            customName: 'Lantern',
            customCategoryName: 'Gear',
            sortOrder: 0,
          ),
        ],
    createdAt: timestamp,
    updatedAt: updatedAt ?? timestamp,
    deletedAt: deletedAt,
  );
}

PackingTemplate sampleSystemTemplate({
  String id = 'sys_tpl_test',
  String nameKey = 'packingTemplateBasicTrip',
  String? groupKey,
  List<PackingTemplateItem>? items,
}) {
  return PackingTemplate(
    id: id,
    nameKey: nameKey,
    descriptionKey: 'packingTemplateBasicTripDesc',
    isSystem: true,
    groupKey: groupKey,
    items:
        items ??
        const [
          PackingTemplateItem(
            id: 'sys_item_1',
            nameKey: 'packingTemplateItemIdentityDocument',
            categoryKey: 'packingTemplateCategoryDocuments',
            priority: PackingPriority.critical,
          ),
          PackingTemplateItem(
            id: 'sys_item_2',
            nameKey: 'packingTemplateItemPhoneCharger',
            categoryKey: 'packingTemplateCategoryElectronics',
          ),
        ],
  );
}

Map<String, String> sampleTemplateLocalizationMap() {
  return const {
    'packingTemplateBasicTrip': 'Travel essentials',
    'packingTemplateBasicTripDesc': 'Essential items for any journey',
    'packingTemplateItemIdentityDocument': 'Identity document',
    'packingTemplateItemPhoneCharger': 'Phone charger',
    'packingTemplateCategoryDocuments': 'Documents',
    'packingTemplateCategoryElectronics': 'Electronics',
    'packingTemplateUnitPiece': 'piece',
  };
}

String sampleLocalizationResolver(String key) {
  return sampleTemplateLocalizationMap()[key] ?? key;
}

int deterministicIdCounter = 0;

String deterministicIdGenerator(String prefix) {
  deterministicIdCounter++;
  return '${prefix}_$deterministicIdCounter';
}

void resetDeterministicIdCounter() {
  deterministicIdCounter = 0;
}
