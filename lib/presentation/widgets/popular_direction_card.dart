import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:travel_cost_planner_europe/core/utils/country_localization_service.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/widgets/app_card.dart';

class PopularDirectionCard extends StatelessWidget {
  const PopularDirectionCard({
    super.key,
    required this.originCountryCode,
    required this.isActive,
    required this.onTap,
  });

  final String originCountryCode;
  final bool isActive;
  final VoidCallback onTap;

  static const String destinationCountryCode = 'HR';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = AppTextStyles.of(context);
    final directionLabel = l10n.routeFromTo(
      CountryLocalizationService.getCountryName(originCountryCode, context),
      CountryLocalizationService.getCountryName(
        destinationCountryCode,
        context,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Text(
              CountryLocalizationService.formatDirectionFlags(
                originCountryCode,
                destinationCountryCode,
              ),
              style: textStyles.title.copyWith(fontSize: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(directionLabel, style: textStyles.subtitle),
                  if (!isActive) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.comingSoon,
                        style: textStyles.caption.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isActive
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
