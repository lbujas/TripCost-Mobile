import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_list_from_templates_service.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_template_merge_service.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_localization.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  const createService = PackingListFromTemplatesService(mergeService);
  final createdAt = DateTime.utc(2026, 6, 14, 9, 0);

  setUp(resetDeterministicIdCounter);

  group('PackingListFromTemplatesService', () {
    test('creates a complete packing list from templates', () {
      final list = createService.create(
        templates: [sampleSystemTemplate()],
        packingListId: 'list_from_tpl',
        listName: 'Trip packing',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: sampleLocalizationResolver,
      );

      expect(list.id, 'list_from_tpl');
      expect(list.name, 'Trip packing');
      expect(list.items, hasLength(2));
      expect(list.customCategories, hasLength(2));
      expect(list.settings.showProgress, isTrue);
    });

    test('assigns packingListId to all generated items', () {
      final list = createService.create(
        templates: [sampleSystemTemplate()],
        packingListId: 'list_from_tpl',
        listName: 'Trip packing',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: sampleLocalizationResolver,
      );

      expect(
        list.items.every((item) => item.packingListId == 'list_from_tpl'),
        isTrue,
      );
    });

    test('creates unique categories without duplication', () {
      final list = createService.create(
        templates: [
          sampleSystemTemplate(),
          sampleSystemTemplate(
            id: 'sys_tpl_dup',
            items: const [
              PackingTemplateItem(
                id: 'dup_item',
                nameKey: 'packingTemplateItemWallet',
                categoryKey: 'packingTemplateCategoryDocuments',
              ),
            ],
          ),
        ],
        packingListId: 'list_from_tpl',
        listName: 'Trip packing',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: sampleLocalizationResolver,
      );

      expect(list.customCategories, hasLength(2));
      expect(
        list.items
            .where((item) => item.name == 'Identity document')
            .map((item) => item.categoryId)
            .toSet(),
        hasLength(1),
      );
    });

    test('resets runtime packed and purchased states', () {
      final list = createService.create(
        templates: [sampleSystemTemplate()],
        packingListId: 'list_from_tpl',
        listName: 'Trip packing',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: sampleLocalizationResolver,
      );

      expect(list.items.every((item) => !item.isPacked), isTrue);
      expect(list.items.every((item) => !item.isPurchased), isTrue);
      expect(list.items.every((item) => item.deletedAt == null), isTrue);
    });

    test('preserves needsPurchase and priority from templates', () {
      final list = createService.create(
        templates: [
          sampleSystemTemplate(
            items: const [
              PackingTemplateItem(
                id: 'item_1',
                nameKey: 'packingTemplateItemTravelAdapter',
                categoryKey: 'packingTemplateCategoryElectronics',
                needsPurchase: true,
                priority: PackingPriority.important,
              ),
            ],
          ),
        ],
        packingListId: 'list_from_tpl',
        listName: 'Trip packing',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: sampleLocalizationResolver,
      );

      expect(list.items.single.needsPurchase, isTrue);
      expect(list.items.single.priority, PackingPriority.important);
    });

    test('supports optional linkedTripId and dates', () {
      final departure = DateTime.utc(2026, 7, 1);
      final returnDate = DateTime.utc(2026, 7, 10);

      final list = createService.create(
        templates: [sampleSystemTemplate()],
        packingListId: 'list_from_tpl',
        listName: ' Trip packing ',
        description: '  Summer trip  ',
        linkedTripId: 'trip_42',
        departureDate: departure,
        returnDate: returnDate,
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: sampleLocalizationResolver,
      );

      expect(list.linkedTripId, 'trip_42');
      expect(list.name, 'Trip packing');
      expect(list.description, 'Summer trip');
      expect(list.departureDate, departure);
      expect(list.returnDate, returnDate);
    });

    test('uses injected deterministic ids', () {
      final list = createService.create(
        templates: [sampleSystemTemplate()],
        packingListId: 'list_from_tpl',
        listName: 'Trip packing',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: sampleLocalizationResolver,
      );

      expect(list.customCategories.first.id, 'packing_cat_1');
      expect(list.items.first.id, 'packing_item_2');
    });

    test('resolves localized names and units', () {
      final list = createService.create(
        templates: [sampleSystemTemplate()],
        packingListId: 'list_from_tpl',
        listName: 'Trip packing',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: sampleLocalizationResolver,
      );

      expect(list.items.first.name, 'Identity document');
      expect(list.customCategories.first.name, 'Documents');
      expect(list.items.first.unit, 'piece');
    });

    test('creates a packing list from the road trip template', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final roadTrip = await loadRoadTripTemplate();
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      final list = createService.create(
        templates: [roadTrip],
        packingListId: 'list_road_trip',
        listName: 'Europe road trip',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: (key) => resolvePackingTemplateKey(l10n, key),
      );

      expect(list.items.length, roadTrip.items.length);
      expect(list.customCategories.length, greaterThanOrEqualTo(8));
      expect(list.items.every((item) => item.name.isNotEmpty), isTrue);
      expect(
        list.items.any(
          (item) => item.name == l10n.packingTemplateItemDrivingLicense,
        ),
        isTrue,
      );
    });

    test('merges road, documents, clothing, and health templates', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final roadTrip = await loadRoadTripTemplate();
      final documents = await loadTemplateById('sys_tpl_documents');
      final clothing = await loadTemplateById('sys_tpl_clothing');
      final health = await loadTemplateById('sys_tpl_health');
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      final list = createService.create(
        templates: [roadTrip, documents, clothing, health],
        packingListId: 'list_merged_core',
        listName: 'Full road trip',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: (key) => resolvePackingTemplateKey(l10n, key),
      );

      expect(
        list.items.length,
        lessThanOrEqualTo(
          roadTrip.items.length +
              documents.items.length +
              clothing.items.length +
              health.items.length,
        ),
      );
      expect(list.items.length, greaterThan(roadTrip.items.length));
      expect(
        list.items.any((item) => item.name == l10n.packingTemplateItemPassport),
        isTrue,
      );
      expect(
        list.items.any(
          (item) => item.name == l10n.packingTemplateItemWarmLayers,
        ),
        isTrue,
      );
    });

    test('merges road, child, beach, and summer templates', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final roadTrip = await loadRoadTripTemplate();
      final child = await loadTemplateById('sys_tpl_with_child');
      final beach = await loadTemplateById('sys_tpl_beach');
      final summer = await loadTemplateById('sys_tpl_summer');
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      final list = createService.create(
        templates: [roadTrip, child, beach, summer],
        packingListId: 'list_family_summer',
        listName: 'Family summer road trip',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: (key) => resolvePackingTemplateKey(l10n, key),
      );

      expect(list.items.length, greaterThan(roadTrip.items.length));
      expect(
        list.items.any(
          (item) => item.name == l10n.packingTemplateItemFavoriteToy,
        ),
        isTrue,
      );
      expect(
        list.items.any((item) => item.name == l10n.packingTemplateItemSwimwear),
        isTrue,
      );
    });

    test('merges camper and camping templates', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final camper = await loadTemplateById('sys_tpl_camper');
      final camping = await loadTemplateById('sys_tpl_camping');
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      final list = createService.create(
        templates: [camper, camping],
        packingListId: 'list_camper',
        listName: 'Camper holiday',
        createdAt: createdAt,
        idGenerator: deterministicIdGenerator,
        localizationResolver: (key) => resolvePackingTemplateKey(l10n, key),
      );

      expect(
        list.items.length,
        lessThanOrEqualTo(camper.items.length + camping.items.length),
      );
      expect(
        list.items.any((item) => item.name == l10n.packingTemplateItemTent),
        isTrue,
      );
      expect(
        list.items.any(
          (item) => item.name == l10n.packingTemplateItemCamperHookupCable,
        ),
        isTrue,
      );
    });
  });
}
