import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_lists_controller.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/packing_list_overview_actions.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_list_creation_method_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_list_detail_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_list_card.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_lists_empty_state.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/ad_banner_widget.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/async_error_view.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class PackingListsScreen extends ConsumerWidget {
  const PackingListsScreen({super.key});

  Future<void> _openCreateScreen(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (context) => const PackingListCreationMethodScreen(),
      ),
    );

    if (!context.mounted || result == null) {
      return;
    }

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).packingListCreated),
        ),
      );
      return;
    }

    if (result is String) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).packingListCreatedFromTemplates,
          ),
        ),
      );
      _openListDetail(context, result);
    }
  }

  void _openListDetail(BuildContext context, String packingListId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (context) => PackingListDetailScreen(packingListId: packingListId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listsAsync = ref.watch(packingListsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.packingLists),
        actions: const [SettingsActionButton()],
      ),
      body: Column(
        children: [
          Expanded(
            child: listsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (_, __) => AsyncErrorView(
                    message: l10n.failedLoadPackingLists,
                    onRetry:
                        () => ref.invalidate(packingListsControllerProvider),
                  ),
              data: (lists) {
                if (lists.isEmpty) {
                  return PackingListsEmptyState(
                    onCreatePressed: () => _openCreateScreen(context, ref),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: lists.length,
                  separatorBuilder:
                      (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final list = lists[index];

                    return PackingListCard(
                      list: list,
                      itemCount: packingListActiveItemCount(list),
                      packedCount: packingListPackedItemCount(list),
                      onTap: () => _openListDetail(context, list.id),
                      onPrint: () => openPackingListPdfExport(context, list),
                      onDuplicate:
                          () => duplicatePackingListFromOverview(
                            context,
                            ref,
                            list,
                          ),
                      onRename:
                          () => showRenamePackingListDialog(context, ref, list),
                      onDelete:
                          () => showDeletePackingListConfirmation(
                            context,
                            ref,
                            list,
                          ),
                    );
                  },
                );
              },
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
      floatingActionButton: listsAsync.maybeWhen(
        data:
            (lists) =>
                lists.isNotEmpty
                    ? FloatingActionButton(
                      onPressed: () => _openCreateScreen(context, ref),
                      tooltip: l10n.createPackingList,
                      child: const Icon(Icons.add),
                    )
                    : null,
        orElse: () => null,
      ),
    );
  }
}
