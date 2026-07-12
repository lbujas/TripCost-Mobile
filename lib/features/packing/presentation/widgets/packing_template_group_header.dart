import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_group_icon_mapper.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_group_localization.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';

class PackingTemplateGroupHeader extends StatelessWidget {
  const PackingTemplateGroupHeader({
    super.key,
    required this.groupKey,
    required this.selectedInGroup,
  });

  final String groupKey;
  final int selectedInGroup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final title = resolvePackingTemplateGroupTitle(l10n, groupKey);
    final hint = resolvePackingTemplateGroupHint(l10n, groupKey);

    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            resolvePackingTemplateGroupIcon(groupKey),
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: textStyles.subtitle)),
                    if (selectedInGroup > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: Text(
                          l10n.packingTemplateGroupSelectedCount(
                            selectedInGroup,
                          ),
                          style: textStyles.caption.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hint,
                  style: textStyles.body.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PackingTemplateEssentialsIntro extends StatelessWidget {
  const PackingTemplateEssentialsIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.packingTemplateEssentialsChooseSections,
          style: textStyles.body.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.packingTemplateEssentialsCombineTemplates,
          style: textStyles.body.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.packingTemplateEssentialsDuplicateItemsRemoved,
          style: textStyles.body.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
