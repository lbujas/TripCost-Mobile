import 'package:flutter/material.dart';
import 'package:travel_cost_planner_europe/features/packing/presentation/theme/packing_status_colors.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';

class PackingStatusChip extends StatelessWidget {
  const PackingStatusChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.emphasized = true,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      backgroundColor: PackingStatusColors.chipBackground(context, color),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    );
  }
}

class PackingStatusAccent extends StatelessWidget {
  const PackingStatusAccent({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: child),
        ],
      ),
    );
  }
}
