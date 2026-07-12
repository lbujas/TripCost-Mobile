import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_checkbox_mode.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list_export_data.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_options.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_page_orientation.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_pdf_scope.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_list_export_data_builder.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_list_from_templates_service.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_template_merge_service.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_localization.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_list_pdf_service.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/services/packing_pdf_fonts.dart';

import '../../packing_pdf_test_helpers.dart';
import '../../packing_template_test_data.dart';

PackingListExportData _sampleExportData({
  String listName = 'Weekend trip',
  List<PackingExportCategoryGroup>? categories,
}) {
  return PackingListExportData(
    listName: listName,
    description: 'Family beach trip with extra notes',
    departureDate: DateTime.utc(2026, 7, 10),
    returnDate: DateTime.utc(2026, 7, 20),
    generatedAt: DateTime.utc(2026, 6, 14),
    totalItems: categories?.fold<int>(0, (sum, c) => sum + c.items.length) ?? 1,
    checkedCount: 0,
    scope: PackingPdfScope.fullList,
    categories:
        categories ??
        [
          const PackingExportCategoryGroup(
            id: 'cat-1',
            name: 'Essentials',
            items: [
              PackingExportItemRow(
                name: 'Passport',
                quantity: 1,
                unit: 'piece',
                isChecked: false,
              ),
            ],
          ),
        ],
  );
}

PackingList _multiPageList() {
  final timestamp = DateTime.utc(2026, 6, 1);
  final categories = <PackingCategory>[];
  final items = <PackingItem>[];

  for (var categoryIndex = 0; categoryIndex < 8; categoryIndex++) {
    final categoryId = 'cat-$categoryIndex';
    categories.add(
      PackingCategory(
        id: categoryId,
        name: 'Category $categoryIndex',
        sortOrder: categoryIndex,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );

    for (var itemIndex = 0; itemIndex < 12; itemIndex++) {
      items.add(
        PackingItem(
          id: 'item-$categoryIndex-$itemIndex',
          packingListId: 'list-multi',
          name:
              'Item $categoryIndex-$itemIndex with a very long descriptive name that should wrap cleanly in the PDF output without clipping any characters',
          categoryId: categoryId,
          quantity: 2,
          unit: 'piece',
          note:
              'Remember to pack this carefully because it includes several accessories and spare parts for the trip.',
          priority:
              itemIndex.isEven
                  ? PackingPriority.important
                  : PackingPriority.normal,
          sortOrder: itemIndex,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );
    }
  }

  return PackingList(
    id: 'list-multi',
    name: 'Multi-page list',
    createdAt: timestamp,
    updatedAt: timestamp,
    customCategories: categories,
    items: items,
  );
}

Future<PackingTemplate> _loadTemplateById(String id) async {
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

Future<PackingList> _largeMergedPackingList() async {
  const mergeService = PackingTemplateMergeService();
  const createService = PackingListFromTemplatesService(mergeService);
  final l10n = await AppLocalizations.delegate.load(const Locale('en'));

  final templates = await Future.wait([
    _loadTemplateById('sys_tpl_car_travel'),
    _loadTemplateById('sys_tpl_documents'),
    _loadTemplateById('sys_tpl_clothing'),
    _loadTemplateById('sys_tpl_toiletries'),
    _loadTemplateById('sys_tpl_health'),
    _loadTemplateById('sys_tpl_electronics'),
    _loadTemplateById('sys_tpl_food_drinks'),
    _loadTemplateById('sys_tpl_home_prep'),
    _loadTemplateById('sys_tpl_final_checks'),
  ]);

  return createService.create(
    templates: templates,
    packingListId: 'list_large_merged_pdf',
    listName: 'Complete Europe road trip',
    createdAt: DateTime.utc(2026, 6, 14),
    idGenerator: deterministicIdGenerator,
    localizationResolver: (key) => resolvePackingTemplateKey(l10n, key),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PackingListPdfService service;

  setUpAll(() async {
    final fonts = await PackingPdfFonts.load();
    service = PackingListPdfService(fonts);
  });

  group('PackingListPdfService', () {
    test('produces non-empty PDF bytes', () async {
      final bytes = await service.generate(
        data: _sampleExportData(),
        options: const PackingPdfOptions(),
        labels: testPackingPdfLabels,
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('generated document has at least one page', () async {
      final bytes = await service.generate(
        data: _sampleExportData(),
        options: const PackingPdfOptions(),
        labels: testPackingPdfLabels,
      );

      expect(bytes.length, greaterThan(500));
    });

    test('Central European characters render without failure', () async {
      for (final sample in centralEuropeanPdfSampleStrings) {
        final bytes = await service.generate(
          data: _sampleExportData(
            listName: sample,
            categories: [
              PackingExportCategoryGroup(
                id: 'cat-ce',
                name: sample,
                items: [
                  PackingExportItemRow(
                    name: sample,
                    quantity: 1,
                    unit: sample,
                    note: sample,
                    isChecked: false,
                  ),
                ],
              ),
            ],
          ),
          options: const PackingPdfOptions(),
          labels: testPackingPdfLabels,
        );

        expect(bytes, isNotEmpty);
        expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      }
    });

    test('long item names and notes do not cause generation failure', () async {
      const builder = PackingListExportDataBuilder();
      final exportData = builder.build(
        list: _multiPageList(),
        options: const PackingPdfOptions(),
      );

      final bytes = await service.generate(
        data: exportData,
        options: const PackingPdfOptions(),
        labels: testPackingPdfLabels,
      );

      expect(bytes, isNotEmpty);
    });

    test('multi-page list generates successfully', () async {
      const builder = PackingListExportDataBuilder();
      final exportData = builder.build(
        list: _multiPageList(),
        options: const PackingPdfOptions(),
      );

      final bytes = await service.generate(
        data: exportData,
        options: const PackingPdfOptions(),
        labels: testPackingPdfLabels,
      );

      expect(bytes.length, greaterThan(5000));
    });

    test('empty checkboxes mode generates successfully', () async {
      final bytes = await service.generate(
        data: _sampleExportData(),
        options: const PackingPdfOptions(
          checkboxMode: PackingCheckboxMode.empty,
        ),
        labels: testPackingPdfLabels,
      );

      expect(bytes, isNotEmpty);
    });

    test('current-state mode generates successfully', () async {
      final bytes = await service.generate(
        data: _sampleExportData(
          categories: [
            const PackingExportCategoryGroup(
              id: 'cat-1',
              name: 'Essentials',
              items: [
                PackingExportItemRow(
                  name: 'Packed item',
                  quantity: 1,
                  unit: 'piece',
                  isChecked: true,
                ),
              ],
            ),
          ],
        ),
        options: const PackingPdfOptions(
          checkboxMode: PackingCheckboxMode.currentState,
        ),
        labels: testPackingPdfLabels,
      );

      expect(bytes, isNotEmpty);
    });

    test('black-and-white mode generates successfully', () async {
      final bytes = await service.generate(
        data: _sampleExportData(),
        options: const PackingPdfOptions(blackAndWhite: true),
        labels: testPackingPdfLabels,
      );

      expect(bytes, isNotEmpty);
    });

    test('landscape mode generates successfully', () async {
      final bytes = await service.generate(
        data: _sampleExportData(),
        options: const PackingPdfOptions(
          pageOrientation: PackingPdfPageOrientation.landscape,
        ),
        labels: testPackingPdfLabels,
      );

      expect(bytes, isNotEmpty);
    });

    test('large merged template list generates PDF successfully', () async {
      const builder = PackingListExportDataBuilder();
      final list = await _largeMergedPackingList();
      final exportData = builder.build(
        list: list,
        options: const PackingPdfOptions(),
      );

      expect(exportData.totalItems, greaterThanOrEqualTo(120));

      final bytes = await service.generate(
        data: exportData,
        options: const PackingPdfOptions(),
        labels: testPackingPdfLabels,
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      expect(bytes.length, greaterThan(10000));
    });

    test(
      'large merged shopping list PDF scope generates successfully',
      () async {
        const builder = PackingListExportDataBuilder();
        final list = await _largeMergedPackingList();
        final exportData = builder.build(
          list: list,
          options: const PackingPdfOptions(scope: PackingPdfScope.shoppingList),
        );

        expect(exportData.totalItems, greaterThan(0));

        final bytes = await service.generate(
          data: exportData,
          options: const PackingPdfOptions(scope: PackingPdfScope.shoppingList),
          labels: testPackingPdfLabels,
        );

        expect(bytes, isNotEmpty);
      },
    );
  });
}
