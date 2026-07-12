import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_detail_controller.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_helpers.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/packing_list_overview_actions.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/edit_packing_list_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/screens/packing_item_form_screen.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_category_section.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_progress_header.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/ad_banner_widget.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/async_error_view.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/settings_action_button.dart';

class PackingListDetailScreen extends ConsumerWidget {
  const PackingListDetailScreen({super.key, required this.packingListId});

  final String packingListId;

  Future<void> _openAddItem(BuildContext context, WidgetRef ref) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder:
            (context) => PackingItemFormScreen(packingListId: packingListId),
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).packingItemSaved)),
      );
    }
  }

  Future<void> _openEditItem(
    BuildContext context,
    WidgetRef ref,
    String itemId,
  ) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder:
            (context) => PackingItemFormScreen(
              packingListId: packingListId,
              itemId: itemId,
            ),
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).packingItemSaved)),
      );
    }
  }

  Future<void> _openPdfExport(BuildContext context, PackingList list) async {
    await openPackingListPdfExport(context, list);
  }

  Future<void> _openEditList(BuildContext context) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder:
            (context) => EditPackingListScreen(packingListId: packingListId),
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).packingListUpdated),
        ),
      );
    }
  }

  Future<void> _confirmDeleteItem(
    BuildContext context,
    WidgetRef ref,
    String itemId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deletePackingItem),
            content: Text(l10n.deletePackingItemQuestion),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(packingListDetailControllerProvider(packingListId).notifier)
          .softDeleteItem(itemId);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.packingItemDeleted)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.failedSavePackingList)));
    }
  }

  Future<void> _runItemAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedSavePackingList),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(
      packingListDetailControllerProvider(packingListId),
    );
    final notifier = ref.read(
      packingListDetailControllerProvider(packingListId).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: listAsync.maybeWhen(
          data: (list) => Text(list.name),
          orElse: () => Text(l10n.packingLists),
        ),
        actions: [
          PopupMenuButton<String>(
            key: const Key('packing_detail_menu'),
            onSelected: (value) {
              if (value == 'edit') {
                _openEditList(context);
              } else if (value == 'export') {
                final list = listAsync.asData?.value;
                if (list != null) {
                  _openPdfExport(context, list);
                }
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(l10n.editPackingList),
                  ),
                  PopupMenuItem(
                    value: 'export',
                    child: Text(l10n.packingPdfPrintExport),
                  ),
                ],
          ),
          const SettingsActionButton(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (_, __) => AsyncErrorView(
                    message: l10n.failedLoadPackingList,
                    onRetry:
                        () => ref.invalidate(
                          packingListDetailControllerProvider(packingListId),
                        ),
                  ),
              data: (list) {
                final categories = packingSortedCategoriesWithActiveItems(list);

                if (categories.isEmpty) {
                  return buildPackingItemsEmptyState(
                    context: context,
                    onAddPressed: () => _openAddItem(context, ref),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    PackingProgressHeader(list: list),
                    const SizedBox(height: AppSpacing.xl),
                    for (var index = 0; index < categories.length; index++) ...[
                      PackingCategorySection(
                        category: categories[index],
                        items: packingSortedActiveItemsForCategory(
                          list,
                          categories[index].id,
                        ),
                        onTogglePacked:
                            (item) => _runItemAction(
                              context,
                              () => notifier.togglePacked(item.id),
                            ),
                        onToggleNeedsPurchase:
                            (item) => _runItemAction(
                              context,
                              () => notifier.toggleNeedsPurchase(item.id),
                            ),
                        onTogglePurchased:
                            (item) => _runItemAction(
                              context,
                              () => notifier.togglePurchased(item.id),
                            ),
                        onEdit: (item) => _openEditItem(context, ref, item.id),
                        onDelete:
                            (item) => _confirmDeleteItem(context, ref, item.id),
                      ),
                      if (index < categories.length - 1)
                        const SizedBox(height: AppSpacing.xl),
                    ],
                  ],
                );
              },
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
      floatingActionButton: listAsync.maybeWhen(
        data:
            (_) => FloatingActionButton(
              onPressed: () => _openAddItem(context, ref),
              tooltip: l10n.addPackingItem,
              child: const Icon(Icons.add),
            ),
        orElse: () => null,
      ),
    );
  }
}
