import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/core/constants/asset_paths.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/features/packing/data/sources/system_packing_template_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SystemPackingTemplateSource source;

  setUp(() {
    source = SystemPackingTemplateSource(const JsonAssetLoader());
  });

  group('SystemPackingTemplateSource', () {
    test('loads bundled asset', () async {
      final templates = await source.getAll();

      expect(templates, isNotEmpty);
    });

    test('parses all system templates', () async {
      final templates = await source.getAll();

      expect(templates.length, 25);
      expect(templates.every((template) => template.isSystem), isTrue);
      expect(
        templates.every(
          (template) =>
              template.nameKey != null && template.nameKey!.isNotEmpty,
        ),
        isTrue,
      );
    });

    test('template ids are unique', () async {
      final templates = await source.getAll();
      final ids = templates.map((template) => template.id).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('item ids are unique within each template', () async {
      final templates = await source.getAll();

      for (final template in templates) {
        final itemIds = template.items.map((item) => item.id).toList();
        expect(itemIds.toSet().length, itemIds.length, reason: template.id);
      }
    });

    test('required localization keys are present structurally', () async {
      final templates = await source.getAll();

      for (final template in templates) {
        expect(template.nameKey, isNotNull);
        for (final item in template.items) {
          expect(item.nameKey, isNotNull);
          expect(item.categoryKey, isNotNull);
          expect(item.unitKey, isNotEmpty);
        }
      }
    });

    test('skips invalid records safely', () async {
      final brokenSource = SystemPackingTemplateSource(_BrokenLoader());

      final templates = await brokenSource.getAll();

      expect(templates, hasLength(1));
      expect(templates.first.id, 'valid');
    });

    test('road trip template has 50-70 vehicle-focused items', () async {
      final templates = await source.getAll();
      final roadTrip = templates.firstWhere(
        (template) => template.id == 'sys_tpl_car_travel',
      );

      expect(roadTrip.items.length, inInclusiveRange(50, 70));
    });

    test('road trip excludes non-vehicle modular categories', () async {
      final templates = await source.getAll();
      final roadTrip = templates.firstWhere(
        (template) => template.id == 'sys_tpl_car_travel',
      );

      const excludedCategories = {
        'packingTemplateCategoryClothing',
        'packingTemplateCategoryToiletries',
        'packingTemplateCategoryFood',
        'packingTemplateCategoryHomePreparation',
        'packingTemplateCategoryJourneyComfort',
        'packingTemplateCategoryHealth',
      };

      for (final item in roadTrip.items) {
        expect(excludedCategories, isNot(contains(item.categoryKey)));
      }
    });

    test(
      'road trip excludes clothing, toiletries, food, and home keys',
      () async {
        final templates = await source.getAll();
        final roadTrip = templates.firstWhere(
          (template) => template.id == 'sys_tpl_car_travel',
        );

        const excludedPrefixes = {
          'packingTemplateItemCloth',
          'packingTemplateItemHygiene',
          'packingTemplateItemFood',
          'packingTemplateItemHome',
          'packingTemplateItemRtTooth',
          'packingTemplateItemRtDeodorant',
          'packingTemplateItemRtSnacks',
          'packingTemplateItemRtNonPerishable',
          'packingTemplateItemRtUnplug',
          'packingTemplateItemRtSecureHome',
          'packingTemplateItemMedicines',
          'packingTemplateItemRtMotionSickness',
          'packingTemplateItemRtPainRelievers',
        };

        for (final item in roadTrip.items) {
          final nameKey = item.nameKey!;
          for (final prefix in excludedPrefixes) {
            expect(nameKey.startsWith(prefix), isFalse, reason: nameKey);
          }
        }
      },
    );

    test('modular templates meet minimum item counts', () async {
      final templates = await source.getAll();
      final byId = {for (final template in templates) template.id: template};

      expect(byId['sys_tpl_documents']!.items.length, inInclusiveRange(18, 25));
      expect(byId['sys_tpl_clothing']!.items.length, inInclusiveRange(35, 50));
      expect(
        byId['sys_tpl_toiletries']!.items.length,
        inInclusiveRange(25, 35),
      );
      expect(byId['sys_tpl_health']!.items.length, inInclusiveRange(28, 40));
      expect(
        byId['sys_tpl_electronics']!.items.length,
        inInclusiveRange(28, 35),
      );
      expect(
        byId['sys_tpl_food_drinks']!.items.length,
        inInclusiveRange(20, 25),
      );
      expect(byId['sys_tpl_home_prep']!.items.length, inInclusiveRange(20, 30));
      expect(
        byId['sys_tpl_final_checks']!.items.length,
        inInclusiveRange(12, 20),
      );
      expect(byId['sys_tpl_summer']!.items.length, inInclusiveRange(10, 15));
      expect(byId['sys_tpl_winter']!.items.length, inInclusiveRange(14, 20));
      expect(
        byId['sys_tpl_motorcycle']!.items.length,
        inInclusiveRange(30, 40),
      );
      expect(byId['sys_tpl_bicycle']!.items.length, inInclusiveRange(28, 35));
      expect(byId['sys_tpl_camper']!.items.length, inInclusiveRange(45, 55));
      expect(byId['sys_tpl_with_baby']!.items.length, inInclusiveRange(50, 70));
      expect(byId['sys_tpl_with_cat']!.items.length, inInclusiveRange(30, 45));
    });

    test('every system template has a groupKey', () async {
      final templates = await source.getAll();

      expect(
        templates.every(
          (template) =>
              template.groupKey != null && template.groupKey!.isNotEmpty,
        ),
        isTrue,
      );
    });

    test('air travel template contains only flight-specific domains', () async {
      final templates = await source.getAll();
      final air = templates.firstWhere(
        (template) => template.id == 'sys_tpl_air_travel',
      );

      const allowedCategories = {
        'packingTemplateCategoryDocuments',
        'packingTemplateCategoryTravelGear',
      };

      for (final item in air.items) {
        expect(allowedCategories, contains(item.categoryKey));
      }
      expect(air.items.map((item) => item.nameKey).toSet(), isNot(contains('packingTemplateItemPhoneCharger')));
    });
  });
}

class _BrokenLoader extends JsonAssetLoader {
  const _BrokenLoader();

  @override
  Future<List<dynamic>> loadJsonList(String path) async {
    expect(path, AssetPaths.packingTemplates);
    return [
      {
        'id': 'valid',
        'nameKey': 'packingTemplateBasicTrip',
        'isSystem': true,
        'items': [],
      },
      'invalid',
      {'isSystem': true, 'items': []},
    ];
  }
}
