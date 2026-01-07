import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_scheme.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.light,
      textTheme: _buildTextTheme(AppColorScheme.light),
      scaffoldBackgroundColor: AppColorScheme.light.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorScheme.light.surface,
        foregroundColor: AppColorScheme.light.onSurface,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.radiusLarge),
        ),
        color: AppColorScheme.light.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorScheme.light.primary,
          foregroundColor: AppColorScheme.light.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing6,
            vertical: AppSpacing.spacing4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.radiusMedium),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorScheme.light.primary,
          side: BorderSide(
            color: AppColorScheme.light.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing6,
            vertical: AppSpacing.spacing4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorScheme.light.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.radiusMedium),
          borderSide: BorderSide(
            color: AppColorScheme.light.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.radiusMedium),
          borderSide: BorderSide(
            color: AppColorScheme.light.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.radiusMedium),
          borderSide: BorderSide(
            color: AppColorScheme.light.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorScheme.dark,
      textTheme: _buildTextTheme(AppColorScheme.dark),
      scaffoldBackgroundColor: AppColorScheme.dark.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorScheme.dark.surface,
        foregroundColor: AppColorScheme.dark.onSurface,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.radiusLarge),
        ),
        color: AppColorScheme.dark.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorScheme.dark.primary,
          foregroundColor: AppColorScheme.dark.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing6,
            vertical: AppSpacing.spacing4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.radiusMedium),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorScheme.dark.primary,
          side: BorderSide(
            color: AppColorScheme.dark.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing6,
            vertical: AppSpacing.spacing4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorScheme.dark.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.radiusMedium),
          borderSide: BorderSide(
            color: AppColorScheme.dark.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.radiusMedium),
          borderSide: BorderSide(
            color: AppColorScheme.dark.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.radiusMedium),
          borderSide: BorderSide(
            color: AppColorScheme.dark.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: colorScheme.onSurface,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: colorScheme.onSurface,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: colorScheme.onSurface,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: colorScheme.onSurface,
      ),
    );
  }
}

