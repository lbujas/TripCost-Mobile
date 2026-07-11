import 'package:flutter/material.dart';

/// Reusable text styles derived from [ThemeData] colors.
class AppTextStyles {
  const AppTextStyles(this._colorScheme);

  final ColorScheme _colorScheme;

  static AppTextStyles of(BuildContext context) {
    return AppTextStyles(Theme.of(context).colorScheme);
  }

  TextStyle get headline => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: _colorScheme.onSurface,
        height: 1.2,
      );

  TextStyle get title => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _colorScheme.onSurface,
        height: 1.3,
      );

  TextStyle get subtitle => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: _colorScheme.onSurface,
        height: 1.35,
      );

  TextStyle get body => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _colorScheme.onSurface,
        height: 1.5,
      );

  TextStyle get caption => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _colorScheme.onSurfaceVariant,
        height: 1.4,
      );

  TextStyle get button => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _colorScheme.onPrimary,
        height: 1.2,
      );

  TextStyle get amountLarge => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: _colorScheme.primary,
        height: 1.1,
      );

  TextTheme toTextTheme() {
    return TextTheme(
      headlineLarge: headline,
      titleLarge: title,
      titleMedium: subtitle,
      bodyLarge: body,
      bodySmall: caption,
      labelLarge: button,
      displaySmall: amountLarge,
    );
  }
}
