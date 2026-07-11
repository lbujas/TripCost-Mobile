import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';

/// Reusable text field with consistent styling.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon == null
              ? null
              : Icon(
                  prefixIcon,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
      ),
    );
  }
}
