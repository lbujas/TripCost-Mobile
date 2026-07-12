import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_template_merge_service.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_template_selection_controller.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

import '../../fake_packing_template_repository.dart';
import '../../packing_template_test_data.dart';

class _TrackingMergeService extends PackingTemplateMergeService {
  _TrackingMergeService(this.onMerge);

  final void Function(List<PackingTemplate> templates) onMerge;
  int mergeCallCount = 0;

  @override
  List<PackingTemplateItem> mergeTemplates(List<PackingTemplate> templates) {
    mergeCallCount++;
    onMerge(templates);
    return super.mergeTemplates(templates);
  }
}

void main() {
  group('PackingTemplateSelectionController', () {
    late FakePackingTemplateRepository repository;
    late _TrackingMergeService mergeService;
    late ProviderContainer container;

    setUp(() {
      repository = FakePackingTemplateRepository();
      mergeService = _TrackingMergeService((_) {});
      container = ProviderContainer(
        overrides: [
          packingTemplateRepositoryProvider.overrideWithValue(repository),
          packingTemplateMergeServiceProvider.overrideWithValue(mergeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads system templates', () async {
      repository.systemTemplates.add(sampleSystemTemplate());

      final state = await container.read(
        packingTemplateSelectionControllerProvider.future,
      );

      expect(state.systemTemplates, hasLength(1));
      expect(state.userTemplates, isEmpty);
      expect(repository.getSystemTemplatesCallCount, 1);
    });

    test('loads system and user templates', () async {
      repository.systemTemplates.add(sampleSystemTemplate());
      repository.userTemplates.add(sampleUserTemplate());

      final state = await container.read(
        packingTemplateSelectionControllerProvider.future,
      );

      expect(state.systemTemplates, hasLength(1));
      expect(state.userTemplates, hasLength(1));
    });

    test('excludes soft-deleted user templates', () async {
      repository.userTemplates.addAll([
        sampleUserTemplate(id: 'active'),
        sampleUserTemplate(id: 'deleted', deletedAt: DateTime.utc(2026, 6, 11)),
      ]);

      final state = await container.read(
        packingTemplateSelectionControllerProvider.future,
      );

      expect(state.userTemplates, hasLength(1));
      expect(state.userTemplates.single.id, 'active');
    });

    test('selects and deselects templates', () async {
      repository.systemTemplates.add(sampleSystemTemplate(id: 'sys_1'));

      await container.read(packingTemplateSelectionControllerProvider.future);
      final notifier = container.read(
        packingTemplateSelectionControllerProvider.notifier,
      );

      notifier.toggleSelection('sys_1');
      expect(
        container
            .read(packingTemplateSelectionControllerProvider)
            .value!
            .selectedIds,
        {'sys_1'},
      );

      notifier.toggleSelection('sys_1');
      expect(
        container
            .read(packingTemplateSelectionControllerProvider)
            .value!
            .selectedIds,
        isEmpty,
      );
    });

    test('prevents duplicate selection', () async {
      repository.systemTemplates.add(sampleSystemTemplate(id: 'sys_1'));

      await container.read(packingTemplateSelectionControllerProvider.future);
      final notifier = container.read(
        packingTemplateSelectionControllerProvider.notifier,
      );

      notifier.toggleSelection('sys_1');
      notifier.toggleSelection('sys_1');
      notifier.toggleSelection('sys_1');

      expect(
        container
            .read(packingTemplateSelectionControllerProvider)
            .value!
            .selectedCount,
        1,
      );
    });

    test('merged counts update correctly', () async {
      repository.systemTemplates.addAll([
        sampleSystemTemplate(
          id: 'sys_1',
          items: const [
            PackingTemplateItem(
              id: 'a',
              nameKey: 'packingTemplateItemIdentityDocument',
              categoryKey: 'packingTemplateCategoryDocuments',
            ),
          ],
        ),
        sampleSystemTemplate(
          id: 'sys_2',
          items: const [
            PackingTemplateItem(
              id: 'b',
              nameKey: 'packingTemplateItemWallet',
              categoryKey: 'packingTemplateCategoryDocuments',
            ),
            PackingTemplateItem(
              id: 'c',
              nameKey: 'packingTemplateItemPhoneCharger',
              categoryKey: 'packingTemplateCategoryElectronics',
            ),
          ],
        ),
      ]);

      await container.read(packingTemplateSelectionControllerProvider.future);
      final notifier = container.read(
        packingTemplateSelectionControllerProvider.notifier,
      );

      notifier.toggleSelection('sys_1');
      notifier.toggleSelection('sys_2');

      expect(notifier.mergedItemCount(), 3);
      expect(notifier.mergedCategoryCount(), 2);
    });

    test('merge service is used', () async {
      repository.systemTemplates.add(sampleSystemTemplate(id: 'sys_1'));

      await container.read(packingTemplateSelectionControllerProvider.future);
      final notifier = container.read(
        packingTemplateSelectionControllerProvider.notifier,
      );

      notifier.toggleSelection('sys_1');
      notifier.mergedItemCount();

      expect(mergeService.mergeCallCount, greaterThan(0));
    });

    test('repository error is exposed', () async {
      repository.systemLoadError = Exception('load failed');

      await expectLater(
        container.read(packingTemplateSelectionControllerProvider.future),
        throwsA(isA<Exception>()),
      );
    });

    test('retry reloads templates', () async {
      repository.systemLoadError = Exception('load failed');

      await Future<void>.delayed(Duration.zero);

      repository.systemLoadError = null;
      repository.systemTemplates.add(sampleSystemTemplate());

      await container
          .read(packingTemplateSelectionControllerProvider.notifier)
          .refresh();

      final state = container.read(packingTemplateSelectionControllerProvider);
      expect(state.hasValue, isTrue);
      expect(state.value!.systemTemplates, hasLength(1));
      expect(repository.getSystemTemplatesCallCount, greaterThan(1));
    });
  });
}
