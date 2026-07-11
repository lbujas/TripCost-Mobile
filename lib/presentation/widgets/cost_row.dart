import 'package:flutter/material.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';

/// Row displaying a cost label and formatted value.
class CostRow extends StatelessWidget {
  const CostRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
    this.largeValue = false,
    this.icon,
  });

  final String label;
  final String value;
  final bool emphasized;
  final bool largeValue;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = emphasized ? textStyles.subtitle : textStyles.body;
    final valueStyle = largeValue
        ? textStyles.amountLarge
        : emphasized
            ? textStyles.subtitle.copyWith(fontWeight: FontWeight.w700)
            : textStyles.body;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: AppSpacing.md),
          Text(value, style: valueStyle, textAlign: TextAlign.end),
        ],
      ),
    );
  }
}
