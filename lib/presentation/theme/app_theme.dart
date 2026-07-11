import 'package:flutter/material.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_colors.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_spacing.dart';
import 'package:travel_cost_planner_europe/presentation/theme/app_text_styles.dart';

/// Application theme configuration for light and dark modes.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        background: AppLightColors.background,
        surface: AppLightColors.surface,
        primary: AppLightColors.primary,
        secondary: AppLightColors.secondary,
        accent: AppLightColors.accent,
        textPrimary: AppLightColors.textPrimary,
        textSecondary: AppLightColors.textSecondary,
        success: AppLightColors.success,
        warning: AppLightColors.warning,
        error: AppLightColors.error,
        border: AppLightColors.border,
        onPrimary: AppLightColors.onPrimary,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        background: AppDarkColors.background,
        surface: AppDarkColors.surface,
        primary: AppDarkColors.primary,
        secondary: AppDarkColors.secondary,
        accent: AppDarkColors.accent,
        textPrimary: AppDarkColors.textPrimary,
        textSecondary: AppDarkColors.textSecondary,
        success: AppDarkColors.success,
        warning: AppDarkColors.warning,
        error: AppDarkColors.error,
        border: AppDarkColors.border,
        onPrimary: AppDarkColors.onPrimary,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color primary,
    required Color secondary,
    required Color accent,
    required Color textPrimary,
    required Color textSecondary,
    required Color success,
    required Color warning,
    required Color error,
    required Color border,
    required Color onPrimary,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onPrimary,
      tertiary: accent,
      onTertiary: onPrimary,
      error: error,
      onError: onPrimary,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
    );

    final textStyles = AppTextStyles(colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textStyles.toTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          textStyle: textStyles.button,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          textStyle: textStyles.button.copyWith(color: primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          side: BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: brightness == Brightness.light ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: brightness == Brightness.dark ? border : Colors.transparent,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: textStyles.caption,
        hintStyle: textStyles.caption,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: brightness == Brightness.light ? 8 : 0,
      ),
      extensions: [
        AppSemanticColors(
          success: success,
          warning: warning,
          accent: accent,
          border: border,
        ),
      ],
    );
  }
}

/// Semantic colors exposed through [ThemeExtension] for success, warning, etc.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.accent,
    required this.border,
  });

  final Color success;
  final Color warning;
  final Color accent;
  final Color border;

  static AppSemanticColors of(BuildContext context) {
    return Theme.of(context).extension<AppSemanticColors>()!;
  }

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? accent,
    Color? border,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      accent: accent ?? this.accent,
      border: border ?? this.border,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) {
      return this;
    }

    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}
