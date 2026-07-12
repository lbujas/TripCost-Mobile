import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_template_selection_controller.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/packing_template_grouping.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/create_packing_list_from_templates_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_template_card.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_template_group_header.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_template_selection_summary.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_button.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/async_error_view.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class PackingTemplateSelectionScreen extends ConsumerWidget {
  const PackingTemplateSelectionScreen({super.key});

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final listId = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (context) => const CreatePackingListFromTemplatesScreen(),
      ),
    );

    if (listId != null && context.mounted) {
      Navigator.of(context).pop(listId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final selectionAsync = ref.watch(
      packingTemplateSelectionControllerProvider,
    );
    final controller = ref.read(
      packingTemplateSelectionControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.packingChooseTemplates),
        actions: const [SettingsActionButton()],
      ),
      body: selectionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (_, __) => AsyncErrorView(
              message: l10n.packingFailedLoadTemplates,
              onRetry: controller.refresh,
            ),
        data: (selection) {
          if (!selection.hasTemplates) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.packingNoTemplatesAvailable,
                  style: textStyles.body,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final selectedCount = selection.selectedCount;
          final mergedItemCount = controller.mergedItemCount();
          final mergedCategoryCount = controller.mergedCategoryCount();
          final groupedSections = PackingTemplateGrouping.groupSystemTemplates(
            selection.systemTemplates,
          );

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    Text(
                      l10n.packingCombineTemplatesHint,
                      style: textStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    for (final section in groupedSections) ...[
                      PackingTemplateGroupHeader(
                        groupKey: section.groupKey,
                        selectedInGroup:
                            PackingTemplateGrouping.selectedCountInGroup(
                              section.templates,
                              selection.selectedIds,
                            ),
                      ),
                      if (section.groupKey ==
                          'packingTemplateGroupEssentials') ...[
                        const SizedBox(height: AppSpacing.sm),
                        const PackingTemplateEssentialsIntro(),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      for (final template in section.templates) ...[
                        PackingTemplateCard(
                          template: template,
                          selected: selection.isSelected(template.id),
                          onChanged:
                              (selected) =>
                                  controller.setSelected(template.id, selected),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (selection.userTemplates.isNotEmpty) ...[
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.packingMyTemplates,
                          style: textStyles.subtitle,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final template in selection.userTemplates) ...[
                        PackingTemplateCard(
                          template: template,
                          selected: selection.isSelected(template.id),
                          onChanged:
                              (selected) =>
                                  controller.setSelected(template.id, selected),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ],
                ),
              ),
              if (selectedCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: PackingTemplateSelectionSummary(
                    selectedCount: selectedCount,
                    mergedItemCount: mergedItemCount,
                    mergedCategoryCount: mergedCategoryCount,
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppButton(
                    label: l10n.packingContinue,
                    onPressed:
                        selectedCount == 0
                            ? null
                            : () => _continue(context, ref),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
