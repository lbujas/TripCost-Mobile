import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';

class PackingTemplateSelectionSummary extends StatelessWidget {
  const PackingTemplateSelectionSummary({
    super.key,
    required this.selectedCount,
    required this.mergedItemCount,
    required this.mergedCategoryCount,
  });

  final int selectedCount;
  final int mergedItemCount;
  final int mergedCategoryCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.packingTemplatesSelectedCount(selectedCount),
            style: textStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.packingItemsAfterMerging(mergedItemCount),
            style: textStyles.body,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.packingCategoriesAfterMerging(mergedCategoryCount),
            style: textStyles.body,
          ),
        ],
      ),
    );
  }
}
