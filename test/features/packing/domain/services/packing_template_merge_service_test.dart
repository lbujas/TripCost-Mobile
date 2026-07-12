import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_template_merge_service.dart';

import '../../packing_template_test_data.dart';

Future<PackingTemplate> loadRoadTripTemplate() async {
  return loadTemplateById('sys_tpl_car_travel');
}

Future<PackingTemplate> loadTemplateById(String id) async {
  final jsonString = await rootBundle.loadString(
    'assets/data/packing_templates.json',
  );
  final templates = jsonDecode(jsonString) as List<dynamic>;
  final templateJson =
      templates.firstWhere(
            (template) => (template as Map<String, dynamic>)['id'] == id,
          )
          as Map<String, dynamic>;

  return PackingTemplate.fromJson(templateJson);
}

void main() {
  const mergeService = PackingTemplateMergeService();

  group('PackingTemplateMergeService', () {
    test('merges several templates and removes exact duplicates', () {
      final basic = sampleSystemTemplate(
        items: const [
          PackingTemplateItem(
            id: 'a1',
            nameKey: 'packingTemplateItemIdentityDocument',
            categoryKey: 'packingTemplateCategoryDocuments',
            quantity: 1,
            sortOrder: 0,
          ),
          PackingTemplateItem(
            id: 'a2',
            nameKey: 'packingTemplateItemPhoneCharger',
            categoryKey: 'packingTemplateCategoryElectronics',
            quantity: 1,
            sortOrder: 1,
          ),
        ],
      );
      final air = sampleSystemTemplate(
        id: 'sys_tpl_air',
        nameKey: 'packingTemplateAirTravel',
        items: const [
          PackingTemplateItem(
            id: 'b1',
            nameKey: 'packingTemplateItemIdentityDocument',
            categoryKey: 'packingTemplateCategoryDocuments',
            quantity: 1,
            priority: PackingPriority.critical,
            sortOrder: 0,
          ),
          PackingTemplateItem(
            id: 'b2',
            nameKey: 'packingTemplateItemHeadphones',
            categoryKey: 'packingTemplateCategoryElectronics',
            sortOrder: 2,
          ),
        ],
      );

      final merged = mergeService.mergeTemplates([basic, air]);

      expect(merged, hasLength(3));
      expect(
        merged.where(
          (item) => item.nameKey == 'packingTemplateItemIdentityDocument',
        ),
        hasLength(1),
      );
    });

    test('does not merge same item name in different categories', () {
      final merged = mergeService.mergeTemplates([
        sampleSystemTemplate(
          items: const [
            PackingTemplateItem(
              id: '1',
              customName: ' Charger ',
              customCategoryName: 'Electronics',
            ),
            PackingTemplateItem(
              id: '2',
              customName: 'charger',
              customCategoryName: 'Travel gear',
            ),
          ],
        ),
      ]);

      expect(merged, hasLength(2));
    });

    test('highest quantity wins for duplicates', () {
      final merged = mergeService.mergeTemplates([
        sampleSystemTemplate(
          items: const [
            PackingTemplateItem(
              id: '1',
              nameKey: 'packingTemplateItemMedicines',
              categoryKey: 'packingTemplateCategoryHealth',
              quantity: 1,
            ),
          ],
        ),
        sampleSystemTemplate(
          id: 'tpl_2',
          items: const [
            PackingTemplateItem(
              id: '2',
              nameKey: 'packingTemplateItemMedicines',
              categoryKey: 'packingTemplateCategoryHealth',
              quantity: 3,
            ),
          ],
        ),
      ]);

      expect(merged.single.quantity, 3);
    });

    test('highest priority wins for duplicates', () {
      final merged = mergeService.mergeTemplates([
        sampleSystemTemplate(
          items: const [
            PackingTemplateItem(
              id: '1',
              nameKey: 'packingTemplateItemMedicines',
              categoryKey: 'packingTemplateCategoryHealth',
              priority: PackingPriority.normal,
            ),
          ],
        ),
        sampleSystemTemplate(
          id: 'tpl_2',
          items: const [
            PackingTemplateItem(
              id: '2',
              nameKey: 'packingTemplateItemMedicines',
              categoryKey: 'packingTemplateCategoryHealth',
              priority: PackingPriority.critical,
            ),
          ],
        ),
      ]);

      expect(merged.single.priority, PackingPriority.critical);
    });

    test('needsPurchase combines with logical OR', () {
      final merged = mergeService.mergeTemplates([
        sampleSystemTemplate(
          items: const [
            PackingTemplateItem(
              id: '1',
              nameKey: 'packingTemplateItemTravelAdapter',
              categoryKey: 'packingTemplateCategoryElectronics',
              needsPurchase: false,
            ),
          ],
        ),
        sampleSystemTemplate(
          id: 'tpl_2',
          items: const [
            PackingTemplateItem(
              id: '2',
              nameKey: 'packingTemplateItemTravelAdapter',
              categoryKey: 'packingTemplateCategoryElectronics',
              needsPurchase: true,
            ),
          ],
        ),
      ]);

      expect(merged.single.needsPurchase, isTrue);
    });

    test('normalizes custom names when matching duplicates', () {
      final merged = mergeService.mergeTemplates([
        sampleSystemTemplate(
          items: const [
            PackingTemplateItem(
              id: '1',
              customName: '  First Aid Kit ',
              customCategoryName: 'Health',
            ),
          ],
        ),
        sampleSystemTemplate(
          id: 'tpl_2',
          items: const [
            PackingTemplateItem(
              id: '2',
              customName: 'first aid kit',
              customCategoryName: 'health',
              quantity: 2,
            ),
          ],
        ),
      ]);

      expect(merged, hasLength(1));
      expect(merged.single.quantity, 2);
    });

    test('returns deterministic ordering', () {
      final first = mergeService.mergeTemplates([
        sampleSystemTemplate(
          items: const [
            PackingTemplateItem(
              id: 'z',
              customName: 'Z item',
              customCategoryName: 'Gear',
              sortOrder: 5,
            ),
            PackingTemplateItem(
              id: 'a',
              customName: 'A item',
              customCategoryName: 'Gear',
              sortOrder: 1,
            ),
          ],
        ),
      ]);
      final second = mergeService.mergeTemplates([
        sampleSystemTemplate(
          items: const [
            PackingTemplateItem(
              id: 'a',
              customName: 'A item',
              customCategoryName: 'Gear',
              sortOrder: 1,
            ),
            PackingTemplateItem(
              id: 'z',
              customName: 'Z item',
              customCategoryName: 'Gear',
              sortOrder: 5,
            ),
          ],
        ),
      ]);

      expect(
        first.map((item) => item.id).toList(),
        second.map((item) => item.id).toList(),
      );
    });

    test('merges road trip with documents and clothing templates', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final roadTrip = await loadRoadTripTemplate();
      final documents = await loadTemplateById('sys_tpl_documents');
      final clothing = await loadTemplateById('sys_tpl_clothing');

      final merged = mergeService.mergeTemplates([
        roadTrip,
        documents,
        clothing,
      ]);

      expect(
        merged.length,
        lessThanOrEqualTo(
          roadTrip.items.length +
              documents.items.length +
              clothing.items.length,
        ),
      );
      expect(merged.length, greaterThan(roadTrip.items.length));
      expect(
        merged.any((item) => item.nameKey == 'packingTemplateItemPassport'),
        isTrue,
      );
      expect(
        merged.any((item) => item.nameKey == 'packingTemplateItemWarmLayers'),
        isTrue,
      );
    });

    test('merges road trip template with child template', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final roadTrip = await loadRoadTripTemplate();
      final child = await loadTemplateById('sys_tpl_with_child');

      final merged = mergeService.mergeTemplates([roadTrip, child]);

      expect(
        merged.length,
        lessThanOrEqualTo(roadTrip.items.length + child.items.length),
      );
      expect(
        merged.any((item) => item.nameKey == 'packingTemplateItemFavoriteToy'),
        isTrue,
      );
      expect(merged.length, greaterThan(roadTrip.items.length));
    });
  });
}
