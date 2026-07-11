import 'package:flutter/material.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_theme.dart';

/// Displays a chain of country codes separated by arrows.
class RouteChain extends StatelessWidget {
  const RouteChain({
    super.key,
    required this.countryCodes,
    this.compact = false,
  });

  final List<String> countryCodes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semanticColors = AppSemanticColors.of(context);
    final textStyles = AppTextStyles.of(context);

    if (compact) {
      return Text(
        countryCodes.join(' → '),
        style: textStyles.caption,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var index = 0; index < countryCodes.length; index++) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: semanticColors.border),
            ),
            child: Text(
              countryCodes[index],
              style: textStyles.caption.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (index < countryCodes.length - 1)
            Icon(
              Icons.arrow_forward,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ],
    );
  }
}
