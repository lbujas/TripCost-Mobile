import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_category.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/theme/packing_status_colors.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_item_tile.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';

class PackingCategorySection extends StatelessWidget {
  const PackingCategorySection({
    super.key,
    required this.category,
    required this.items,
    required this.onTogglePacked,
    required this.onToggleNeedsPurchase,
    required this.onTogglePurchased,
    required this.onEdit,
    required this.onDelete,
  });

  final PackingCategory category;
  final List<PackingItem> items;
  final ValueChanged<PackingItem> onTogglePacked;
  final ValueChanged<PackingItem> onToggleNeedsPurchase;
  final ValueChanged<PackingItem> onTogglePurchased;
  final ValueChanged<PackingItem> onEdit;
  final ValueChanged<PackingItem> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final packedCount = items.where((item) => item.isPacked).length;
    final totalCount = items.length;
    final allPacked = totalCount > 0 && packedCount == totalCount;
    final packedColor = PackingStatusColors.packed(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: allPacked ? packedColor : colorScheme.outlineVariant,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              if (allPacked) ...[
                Icon(Icons.check_circle_outline, color: packedColor, size: 20),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  category.name,
                  style: textStyles.subtitle.copyWith(
                    color: allPacked ? packedColor : colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                l10n.packingCategoryPackedProgress(packedCount, totalCount),
                style: textStyles.caption.copyWith(
                  color: allPacked ? packedColor : colorScheme.onSurfaceVariant,
                  fontWeight: allPacked ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var index = 0; index < items.length; index++) ...[
          PackingItemTile(
            item: items[index],
            onTogglePacked: () => onTogglePacked(items[index]),
            onToggleNeedsPurchase: () => onToggleNeedsPurchase(items[index]),
            onTogglePurchased: () => onTogglePurchased(items[index]),
            onEdit: () => onEdit(items[index]),
            onDelete: () => onDelete(items[index]),
          ),
          if (index < items.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

Widget buildPackingItemsEmptyState({
  required BuildContext context,
  required VoidCallback onAddPressed,
}) {
  final l10n = AppLocalizations.of(context);
  final textStyles = AppTextStyles.of(context);
  final colorScheme = Theme.of(context).colorScheme;

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.noPackingItemsYet,
            style: textStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.addFirstPackingItem,
            style: textStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: Text(l10n.addPackingItem),
          ),
        ],
      ),
    ),
  );
}
