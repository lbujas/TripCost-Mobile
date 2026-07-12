import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:travel_cost_planner_europe/data/local/hive_service.dart';
import 'package:travel_cost_planner_europe/data/local/json_asset_loader.dart';
import 'package:travel_cost_planner_europe/features/packing/data/repositories/packing_template_repository_impl.dart';
import 'package:travel_cost_planner_europe/features/packing/data/sources/system_packing_template_source.dart';
import 'package:travel_cost_planner_europe/features/packing/data/sources/user_packing_template_local_source.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';

import '../../packing_template_test_data.dart';

class FakeSystemPackingTemplateSource extends SystemPackingTemplateSource {
  FakeSystemPackingTemplateSource(this.templates)
    : super(const JsonAssetLoader());

  final List<PackingTemplate> templates;

  @override
  Future<List<PackingTemplate>> getAll() async => templates;
}

void main() {
  late Directory tempDir;
  late HiveService hiveService;
  late FakeSystemPackingTemplateSource systemSource;
  late UserPackingTemplateLocalSource userSource;
  late PackingTemplateRepositoryImpl repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'packing_template_repository_test_',
    );
    Hive.init(tempDir.path);
  });

  setUp(() async {
    hiveService = await HiveService.open();
    systemSource = FakeSystemPackingTemplateSource([
      sampleSystemTemplate(id: 'sys_tpl_test'),
    ]);
    userSource = UserPackingTemplateLocalSource(hiveService);
    repository = PackingTemplateRepositoryImpl(systemSource, userSource);
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

  group('PackingTemplateRepositoryImpl', () {
    test('returns system templates', () async {
      final templates = await repository.getSystemTemplates();

      expect(templates, hasLength(1));
      expect(templates.first.isSystem, isTrue);
    });

    test('returns user templates excluding deleted', () async {
      await userSource.put(sampleUserTemplate());
      await userSource.put(
        sampleUserTemplate(
          id: 'user_tpl_2',
          deletedAt: DateTime.utc(2026, 6, 11),
        ),
      );

      final templates = await repository.getUserTemplates();

      expect(templates, hasLength(1));
      expect(templates.first.id, 'user_tpl_1');
    });

    test(
      'getAllTemplates returns system and user templates together',
      () async {
        await userSource.put(sampleUserTemplate());

        final templates = await repository.getAllTemplates();

        expect(templates, hasLength(2));
      },
    );

    test('getTemplateById finds system and user templates', () async {
      await userSource.put(sampleUserTemplate());

      expect(
        (await repository.getTemplateById('sys_tpl_test'))?.isSystem,
        isTrue,
      );
      expect(
        (await repository.getTemplateById('user_tpl_1'))?.customName,
        'Weekend camping',
      );
    });

    test('saveUserTemplate stores and updates user template', () async {
      await repository.saveUserTemplate(sampleUserTemplate());

      final saved = await userSource.getById('user_tpl_1');
      expect(saved, isNotNull);
      expect(saved!.createdAt, isNotNull);

      await repository.saveUserTemplate(
        sampleUserTemplate(name: 'Updated camping'),
      );

      final updated = await userSource.getById('user_tpl_1');
      expect(updated!.customName, 'Updated camping');
    });

    test('rejects saving system template', () async {
      await expectLater(
        repository.saveUserTemplate(sampleSystemTemplate()),
        throwsA(isA<StateError>()),
      );
    });

    test('soft delete and restore user template', () async {
      await userSource.put(sampleUserTemplate());

      await repository.softDeleteUserTemplate('user_tpl_1');
      expect(await repository.getTemplateById('user_tpl_1'), isNull);

      await repository.restoreUserTemplate('user_tpl_1');
      expect(await repository.getTemplateById('user_tpl_1'), isNotNull);
    });

    test('rejects deleting system template', () async {
      await expectLater(
        repository.softDeleteUserTemplate('sys_tpl_test'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
