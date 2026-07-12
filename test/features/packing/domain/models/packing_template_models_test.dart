import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template_item.dart';

void main() {
  group('PackingTemplate', () {
    test('parses complete system template fromJson', () {
      final template = PackingTemplate.fromJson({
        'id': 'sys_tpl_basic_trip',
        'nameKey': 'packingTemplateBasicTrip',
        'descriptionKey': 'packingTemplateBasicTripDesc',
        'iconKey': 'luggage',
        'isSystem': true,
        'items': [
          {
            'id': 'basic_identity',
            'nameKey': 'packingTemplateItemIdentityDocument',
            'categoryKey': 'packingTemplateCategoryDocuments',
            'quantity': 1,
            'unitKey': 'packingTemplateUnitPiece',
            'priority': 'critical',
            'needsPurchase': false,
            'sortOrder': 0,
          },
        ],
      });

      expect(template.id, 'sys_tpl_basic_trip');
      expect(template.nameKey, 'packingTemplateBasicTrip');
      expect(template.isSystem, isTrue);
      expect(template.items, hasLength(1));
      expect(template.items.first.priority, PackingPriority.critical);
    });

    test('parses optional groupKey fromJson', () {
      final template = PackingTemplate.fromJson({
        'id': 'sys_tpl_air_travel',
        'nameKey': 'packingTemplateAirTravel',
        'groupKey': 'packingTemplateGroupTransport',
        'isSystem': true,
        'items': [],
      });

      expect(template.groupKey, 'packingTemplateGroupTransport');
    });

    test('parses user template fromJson', () {
      final template = PackingTemplate.fromJson({
        'id': 'user_tpl_1',
        'customName': 'Weekend trip',
        'customDescription': 'My custom list',
        'isSystem': false,
        'createdAt': '2026-06-10T12:00:00.000Z',
        'updatedAt': '2026-06-10T12:00:00.000Z',
        'items': [
          {
            'id': 'item_1',
            'customName': 'Lantern',
            'customCategoryName': 'Gear',
            'quantity': 2,
            'unitKey': 'packingTemplateUnitPiece',
          },
        ],
      });

      expect(template.customName, 'Weekend trip');
      expect(template.nameKey, isNull);
      expect(template.items.first.customName, 'Lantern');
      expect(template.items.first.quantity, 2);
    });

    test('defaults missing item collections to empty list', () {
      final template = PackingTemplate.fromJson({
        'id': 'tpl_empty',
        'customName': 'Empty',
      });

      expect(template.items, isEmpty);
    });

    test('round-trips user template toJson', () {
      final original = PackingTemplate(
        id: 'user_tpl_1',
        customName: 'Custom',
        isSystem: false,
        items: const [
          PackingTemplateItem(
            id: 'item_1',
            customName: 'Boots',
            customCategoryName: 'Clothing',
          ),
        ],
        createdAt: DateTime.utc(2026, 6, 1),
        updatedAt: DateTime.utc(2026, 6, 2),
      );

      final restored = PackingTemplate.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.customName, original.customName);
      expect(restored.items.first.customName, 'Boots');
    });

    test('returns unmodifiable item collection', () {
      final template = PackingTemplate(
        id: 'tpl_1',
        customName: 'Test',
        items: const [PackingTemplateItem(id: 'i1', customName: 'A')],
      );

      expect(
        () => template.items.add(
          const PackingTemplateItem(id: 'i2', customName: 'B'),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('PackingTemplateItem', () {
    test('uses defaults for missing optional fields', () {
      final item = PackingTemplateItem.fromJson({
        'id': 'item_1',
        'nameKey': 'packingTemplateItemWallet',
        'categoryKey': 'packingTemplateCategoryDocuments',
      });

      expect(item.quantity, 1);
      expect(item.unitKey, 'packingTemplateUnitPiece');
      expect(item.priority, PackingPriority.normal);
      expect(item.needsPurchase, isFalse);
      expect(item.sortOrder, 0);
    });

    test('falls back to normal priority for unknown values', () {
      final item = PackingTemplateItem.fromJson({
        'id': 'item_1',
        'customName': 'Test',
        'priority': 'unknown',
      });

      expect(item.priority, PackingPriority.normal);
    });

    test('parses legacy double quantity as integer', () {
      final item = PackingTemplateItem.fromJson({
        'id': 'item_1',
        'customName': 'Test',
        'quantity': 3.0,
      });

      expect(item.quantity, 3);
    });

    test('round-trips complete item', () {
      const item = PackingTemplateItem(
        id: 'item_1',
        nameKey: 'packingTemplateItemMedicines',
        categoryKey: 'packingTemplateCategoryHealth',
        quantity: 2,
        unitKey: 'packingTemplateUnitPack',
        priority: PackingPriority.important,
        needsPurchase: true,
        noteKey: 'packingTemplateNotePrescriptionMeds',
        sortOrder: 3,
      );

      final restored = PackingTemplateItem.fromJson(item.toJson());

      expect(restored.id, item.id);
      expect(restored.nameKey, item.nameKey);
      expect(restored.priority, item.priority);
      expect(restored.needsPurchase, item.needsPurchase);
    });
  });
}
