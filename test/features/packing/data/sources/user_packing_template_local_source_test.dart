import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/features/packing/data/sources/user_packing_template_local_source.dart';

import '../../packing_template_test_data.dart';

void main() {
  late Directory tempDir;
  late HiveService hiveService;
  late UserPackingTemplateLocalSource localSource;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'packing_template_local_source_test_',
    );
    Hive.init(tempDir.path);
  });

  setUp(() async {
    hiveService = await HiveService.open();
    localSource = UserPackingTemplateLocalSource(hiveService);
  });

  tearDown(() async {
    await hiveService.packingTemplatesBox.clear();
    await Hive.close();
  });

  tearDownAll(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('UserPackingTemplateLocalSource', () {
    test('returns empty storage when box is empty', () async {
      final templates = await localSource.getAll(includeDeleted: false);

      expect(templates, isEmpty);
    });

    test('saves and reads a user template by id', () async {
      final template = sampleUserTemplate(id: 'user_tpl_1');

      await localSource.put(template);

      final loaded = await localSource.getById('user_tpl_1');
      expect(loaded, isNotNull);
      expect(loaded!.customName, 'Weekend camping');
    });

    test('stores each template under its id key', () async {
      await localSource.put(sampleUserTemplate(id: 'user_tpl_1'));
      await localSource.put(
        sampleUserTemplate(id: 'user_tpl_2', name: 'Other'),
      );

      expect(hiveService.packingTemplatesBox.length, 2);
      expect(hiveService.packingTemplatesBox.get('user_tpl_1'), isNotNull);
      expect(hiveService.packingTemplatesBox.get('user_tpl_2'), isNotNull);
    });

    test('excludes soft-deleted templates by default', () async {
      await localSource.put(
        sampleUserTemplate(
          id: 'user_tpl_1',
          deletedAt: DateTime.utc(2026, 6, 11),
        ),
      );

      final active = await localSource.getAll(includeDeleted: false);
      final all = await localSource.getAll(includeDeleted: true);

      expect(active, isEmpty);
      expect(all, hasLength(1));
    });

    test('skips corrupted records during read', () async {
      await hiveService.packingTemplatesBox.put('broken', 'not-a-map');
      await localSource.put(sampleUserTemplate(id: 'user_tpl_1'));

      final templates = await localSource.getAll(includeDeleted: false);

      expect(templates, hasLength(1));
      expect(templates.first.id, 'user_tpl_1');
    });
  });
}
