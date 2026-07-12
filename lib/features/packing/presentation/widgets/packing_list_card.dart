import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_helpers.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/theme/packing_status_colors.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';

class PackingListCard extends StatelessWidget {
  const PackingListCard({
    super.key,
    required this.list,
    required this.itemCount,
    required this.packedCount,
    required this.onTap,
    this.onPrint,
    this.onDuplicate,
    this.onRename,
    this.onDelete,
  });

  final PackingList list;
  final int itemCount;
  final int packedCount;
  final VoidCallback onTap;
  final VoidCallback? onPrint;
  final VoidCallback? onDuplicate;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final progress = itemCount == 0 ? 0.0 : packedCount / itemCount;
    final progressPercent = packingOverviewProgressPercent(
      packedCount,
      itemCount,
    );
    final remainingCount = packingOverviewRemainingCount(
      packedCount,
      itemCount,
    );
    final toBuyCount = packingOverviewToBuyCount(packingActiveItems(list));
    final progressColor = PackingStatusColors.progressBar(
      context,
      progressPercent,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.name,
                    style: textStyles.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (list.description != null &&
                      list.description!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      list.description!,
                      style: textStyles.body.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (list.departureDate != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.packingListDepartureDate(
                        MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(list.departureDate!),
                      ),
                      style: textStyles.caption,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.packingListItemsCount(itemCount),
                    style: textStyles.body,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _QuickActionBar(
              onPrint: onPrint,
              onDuplicate: onDuplicate,
              onRename: onRename,
              onDelete: onDelete,
            ),
          ),
          if (itemCount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _OverviewStat(
                        label: l10n.packingOverviewPackedCount(packedCount),
                        icon: Icons.check_circle_outline,
                        color: PackingStatusColors.packed(context),
                      ),
                      _OverviewStat(
                        label: l10n.packingOverviewRemainingCount(
                          remainingCount,
                        ),
                        icon: Icons.backpack_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      if (toBuyCount > 0)
                        _OverviewStat(
                          label: l10n.packingOverviewToBuyCount(toBuyCount),
                          icon: Icons.shopping_cart_outlined,
                          color: PackingStatusColors.needsPurchase(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.packingListPackedSummary(packedCount, itemCount),
                        style: textStyles.body,
                      ),
                      Text(
                        l10n.packingListProgressPercent(progressPercent),
                        style: textStyles.caption.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      color: progressColor,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.packingListProgress(packedCount, itemCount),
                    style: textStyles.caption.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Text(
              l10n.packingListLastUpdated(
                MaterialLocalizations.of(
                  context,
                ).formatMediumDate(list.updatedAt.toLocal()),
              ),
              style: textStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: textStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuickActionBar extends StatelessWidget {
  const _QuickActionBar({
    this.onPrint,
    this.onDuplicate,
    this.onRename,
    this.onDelete,
  });

  final VoidCallback? onPrint;
  final VoidCallback? onDuplicate;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 0,
      runSpacing: 0,
      children: [
        IconButton(
          key: const Key('packing_list_print_action'),
          tooltip: l10n.packingPdfPrintExport,
          visualDensity: VisualDensity.compact,
          onPressed: onPrint,
          icon: const Icon(Icons.print_outlined),
        ),
        IconButton(
          key: const Key('packing_list_duplicate_action'),
          tooltip: l10n.duplicatePackingList,
          visualDensity: VisualDensity.compact,
          onPressed: onDuplicate,
          icon: const Icon(Icons.copy_outlined),
        ),
        IconButton(
          key: const Key('packing_list_rename_action'),
          tooltip: l10n.renamePackingList,
          visualDensity: VisualDensity.compact,
          onPressed: onRename,
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          key: const Key('packing_list_delete_action'),
          tooltip: l10n.deletePackingList,
          visualDensity: VisualDensity.compact,
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
