import 'package:flutter/material.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';

/// Primary action button used across the app.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    final button = icon == null
        ? ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: onPrimary,
                    ),
                  )
                : Text(label),
          )
        : ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: onPrimary,
                    ),
                  )
                : Icon(icon),
            label: Text(label),
          );

    if (!expand) {
      return button;
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: button,
      ),
    );
  }
}
