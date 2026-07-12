import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/features/packing/domain/models/packing_template.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_icon_mapper.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/localization/packing_template_localization.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';

class PackingTemplateCard extends StatelessWidget {
  const PackingTemplateCard({
    super.key,
    required this.template,
    required this.selected,
    required this.onChanged,
  });

  final PackingTemplate template;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final name = resolvePackingTemplateName(
      l10n,
      nameKey: template.nameKey,
      customName: template.customName,
    );
    final description = resolvePackingTemplateDescription(
      l10n,
      descriptionKey: template.descriptionKey,
      customDescription: template.customDescription,
    );

    return Semantics(
      checked: selected,
      label: name,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: selected,
              onChanged: (value) => onChanged(value ?? false),
            ),
            Expanded(
              child: InkWell(
                onTap: () => onChanged(!selected),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      resolvePackingTemplateIcon(template.iconKey),
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: textStyles.subtitle),
                          if (description != null &&
                              description.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              description,
                              style: textStyles.body.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.packingListItemsCount(template.items.length),
                            style: textStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
