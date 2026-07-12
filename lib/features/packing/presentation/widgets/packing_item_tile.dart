import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_item.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_priority.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/theme/packing_status_colors.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/widgets/packing_status_chip.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';

class PackingItemTile extends StatelessWidget {
  const PackingItemTile({
    super.key,
    required this.item,
    required this.onTogglePacked,
    required this.onToggleNeedsPurchase,
    required this.onTogglePurchased,
    required this.onEdit,
    required this.onDelete,
  });

  final PackingItem item;
  final VoidCallback onTogglePacked;
  final VoidCallback onToggleNeedsPurchase;
  final VoidCallback onTogglePurchased;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _priorityLabel(AppLocalizations l10n, PackingPriority priority) {
    switch (priority) {
      case PackingPriority.normal:
        return l10n.packingPriorityNormal;
      case PackingPriority.important:
        return l10n.packingPriorityImportant;
      case PackingPriority.critical:
        return l10n.packingPriorityCritical;
    }
  }

  IconData _priorityIcon(PackingPriority priority) {
    switch (priority) {
      case PackingPriority.normal:
        return Icons.flag_outlined;
      case PackingPriority.important:
        return Icons.flag;
      case PackingPriority.critical:
        return Icons.priority_high;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final quantityLabel = item.quantity.toString();
    final accentColor = PackingStatusColors.itemAccentColor(context, item);
    final packedColor = PackingStatusColors.packed(context);
    final notPackedColor = PackingStatusColors.notPacked(context);
    final purchaseColor = PackingStatusColors.needsPurchase(context);
    final disabledColor = PackingStatusColors.disabled(context);
    final packedStatusColor = item.isPacked ? packedColor : notPackedColor;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: PackingStatusAccent(
        color: accentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: item.isPacked,
                  onChanged: (_) => onTogglePacked(),
                  activeColor: packedColor,
                  checkColor: colorScheme.onPrimary,
                  side: BorderSide(
                    color: item.isPacked ? packedColor : notPackedColor,
                    width: 1.5,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: textStyles.subtitle.copyWith(
                          color:
                              item.isPacked
                                  ? colorScheme.onSurface.withValues(
                                    alpha: 0.72,
                                  )
                                  : colorScheme.onSurface,
                          decoration:
                              item.isPacked ? TextDecoration.lineThrough : null,
                          decorationColor: packedColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '$quantityLabel ${item.unit}',
                        style: textStyles.body.copyWith(
                          color:
                              item.isPacked
                                  ? disabledColor
                                  : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                      case 'delete':
                        onDelete();
                      case 'purchase':
                        onToggleNeedsPurchase();
                      case 'purchased':
                        onTogglePurchased();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(l10n.editPackingItem),
                        ),
                        PopupMenuItem(
                          value: 'purchase',
                          child: Text(
                            item.needsPurchase
                                ? l10n.packingNeedsPurchaseOff
                                : l10n.packingNeedsPurchase,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'purchased',
                          child: Text(
                            item.isPurchased
                                ? l10n.packingNotPurchased
                                : l10n.packingPurchased,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            l10n.deletePackingItem,
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                PackingStatusChip(
                  label:
                      item.isPacked ? l10n.packingPacked : l10n.packingUnpacked,
                  icon:
                      item.isPacked
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked,
                  color: packedStatusColor,
                ),
                if (item.needsPurchase)
                  PackingStatusChip(
                    label: l10n.packingNeedsPurchase,
                    icon: Icons.shopping_cart_outlined,
                    color: purchaseColor,
                  ),
                if (item.needsPurchase)
                  PackingStatusChip(
                    label:
                        item.isPurchased
                            ? l10n.packingPurchased
                            : l10n.packingNotPurchased,
                    icon:
                        item.isPurchased
                            ? Icons.check_circle_outline
                            : Icons.shopping_bag_outlined,
                    color: item.isPurchased ? packedColor : purchaseColor,
                    emphasized: !item.isPurchased,
                  ),
                if (item.priority != PackingPriority.normal)
                  PackingStatusChip(
                    label: _priorityLabel(l10n, item.priority),
                    icon: _priorityIcon(item.priority),
                    color: colorScheme.primary,
                    emphasized: false,
                  ),
              ],
            ),
            if (item.note != null && item.note!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.note!,
                style: textStyles.caption.copyWith(color: disabledColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
