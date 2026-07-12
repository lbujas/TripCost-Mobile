import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_list.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/controllers/packing_list_helpers.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/theme/packing_status_colors.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';

class PackingProgressHeader extends StatelessWidget {
  const PackingProgressHeader({super.key, required this.list});

  final PackingList list;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final total = packingActiveItemCount(list);
    final packed = packingPackedActiveItemCount(list);
    final progress = total == 0 ? 0.0 : packed / total;
    final progressPercent = packingOverviewProgressPercent(packed, total);
    final progressColor = PackingStatusColors.progressBar(
      context,
      progressPercent,
    );
    final remainingCount = packingOverviewRemainingCount(packed, total);
    final toBuyCount = packingOverviewToBuyCount(packingActiveItems(list));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.packingProgress, style: textStyles.subtitle),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            _OverviewStat(
              label: l10n.packingOverviewPackedCount(packed),
              icon: Icons.check_circle_outline,
              color: PackingStatusColors.packed(context),
            ),
            _OverviewStat(
              label: l10n.packingOverviewRemainingCount(remainingCount),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: total == 0 ? null : progress,
            minHeight: 8,
            color: progressColor,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.packingListProgress(packed, total), style: textStyles.body),
        if (list.description != null && list.description!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            list.description!,
            style: textStyles.caption.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
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
