import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/services/packing_template_merge_service.dart';
import 'package:travel_cost_planner_europe/presentation/providers/app_providers.dart';

class PackingTemplateSelectionState {
  const PackingTemplateSelectionState({
    required this.systemTemplates,
    required this.userTemplates,
    required this.selectedIds,
  });

  final List<PackingTemplate> systemTemplates;
  final List<PackingTemplate> userTemplates;
  final Set<String> selectedIds;

  int get selectedCount => selectedIds.length;

  bool isSelected(String templateId) => selectedIds.contains(templateId);

  List<PackingTemplate> get allTemplates => [
    ...systemTemplates,
    ...userTemplates,
  ];

  bool get hasTemplates =>
      systemTemplates.isNotEmpty || userTemplates.isNotEmpty;
}

final packingTemplateSelectionControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      PackingTemplateSelectionController,
      PackingTemplateSelectionState
    >(PackingTemplateSelectionController.new);

class PackingTemplateSelectionController
    extends AutoDisposeAsyncNotifier<PackingTemplateSelectionState> {
  @override
  Future<PackingTemplateSelectionState> build() async {
    return _loadTemplates();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadTemplates);
  }

  void setSelected(String templateId, bool selected) {
    final current = state.requireValue;
    final selectedIds = Set<String>.from(current.selectedIds);
    final isSelected = selectedIds.contains(templateId);

    if (selected && !isSelected) {
      selectedIds.add(templateId);
    } else if (!selected && isSelected) {
      selectedIds.remove(templateId);
    } else {
      return;
    }

    state = AsyncData(
      PackingTemplateSelectionState(
        systemTemplates: current.systemTemplates,
        userTemplates: current.userTemplates,
        selectedIds: selectedIds,
      ),
    );
  }

  void toggleSelection(String templateId) {
    final current = state.requireValue;
    final selectedIds = Set<String>.from(current.selectedIds);

    if (selectedIds.contains(templateId)) {
      selectedIds.remove(templateId);
    } else {
      selectedIds.add(templateId);
    }

    state = AsyncData(
      PackingTemplateSelectionState(
        systemTemplates: current.systemTemplates,
        userTemplates: current.userTemplates,
        selectedIds: selectedIds,
      ),
    );
  }

  List<PackingTemplate> selectedTemplates() {
    final current = state.requireValue;
    return current.allTemplates
        .where((template) => current.selectedIds.contains(template.id))
        .toList();
  }

  int mergedItemCount() {
    return _mergeService.mergeTemplates(selectedTemplates()).length;
  }

  int mergedCategoryCount() {
    final mergedItems = _mergeService.mergeTemplates(selectedTemplates());
    return mergedItems.map(_categoryIdentityKey).toSet().length;
  }

  PackingTemplateMergeService get _mergeService {
    return ref.read(packingTemplateMergeServiceProvider);
  }

  Future<PackingTemplateSelectionState> _loadTemplates() async {
    final repository = ref.read(packingTemplateRepositoryProvider);
    final systemTemplates = await repository.getSystemTemplates();
    final userTemplates = await repository.getUserTemplates();

    return PackingTemplateSelectionState(
      systemTemplates: systemTemplates,
      userTemplates: userTemplates,
      selectedIds: const {},
    );
  }

  String _categoryIdentityKey(PackingTemplateItem item) {
    if (item.categoryKey != null) {
      return 'key:${item.categoryKey}';
    }

    return 'name:${normalizeText(item.customCategoryName ?? '')}';
  }
}
