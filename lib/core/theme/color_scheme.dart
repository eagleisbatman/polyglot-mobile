import 'package:flutter/material.dart';

class AppColorScheme {
  AppColorScheme._();

  // Light Mode Colors
  static const ColorScheme light = ColorScheme.light(
    primary: Color(0xFF2563EB), // Blue 600
    onPrimary: Color(0xFFFFFFFF), // White
    primaryContainer: Color(0xFFDBEAFE), // Blue 100
    onPrimaryContainer: Color(0xFF1E3A8A), // Blue 900

    secondary: Color(0xFF64748B), // Slate 500
    onSecondary: Color(0xFFFFFFFF), // White
    secondaryContainer: Color(0xFFF1F5F9), // Slate 100
    onSecondaryContainer: Color(0xFF1E293B), // Slate 800

    tertiary: Color(0xFF7C3AED), // Violet 600
    onTertiary: Color(0xFFFFFFFF), // White
    tertiaryContainer: Color(0xFFEDE9FE), // Violet 100
    onTertiaryContainer: Color(0xFF4C1D95), // Violet 900

    error: Color(0xFFEF4444), // Red 500
    onError: Color(0xFFFFFFFF), // White
    errorContainer: Color(0xFFFEE2E2), // Red 100
    onErrorContainer: Color(0xFF991B1B), // Slate 900
    surface: Color(0xFFFFFFFF), // White
    onSurface: Color(0xFF0F172A), // Slate 900
    surfaceContainerHighest: Color(0xFFF1F5F9), // Slate 100
    onSurfaceVariant: Color(0xFF475569), // Slate 600

    outline: Color(0xFF94A3B8), // Slate 400
    outlineVariant: Color(0xFFE2E8F0), // Slate 200
    shadow: Color(0xFF000000), // Black
    scrim: Color(0xFF000000), // Black
    inverseSurface: Color(0xFF1E293B), // Slate 800
    onInverseSurface: Color(0xFFF1F5F9), // Slate 100
    inversePrimary: Color(0xFF60A5FA), // Blue 400
  );

  // Dark Mode Colors
  static const ColorScheme dark = ColorScheme.dark(
    primary: Color(0xFF60A5FA), // Blue 400
    onPrimary: Color(0xFF1E3A8A), // Blue 900
    primaryContainer: Color(0xFF1E40AF), // Blue 800
    onPrimaryContainer: Color(0xFFDBEAFE), // Blue 100

    secondary: Color(0xFF94A3B8), // Slate 400
    onSecondary: Color(0xFF1E293B), // Slate 800
    secondaryContainer: Color(0xFF334155), // Slate 700
    onSecondaryContainer: Color(0xFFF1F5F9), // Slate 100

    tertiary: Color(0xFFA78BFA), // Violet 400
    onTertiary: Color(0xFF4C1D95), // Violet 900
    tertiaryContainer: Color(0xFF5B21B6), // Violet 800
    onTertiaryContainer: Color(0xFFEDE9FE), // Violet 100

    error: Color(0xFFF87171), // Red 400
    onError: Color(0xFF991B1B), // Red 800
    errorContainer: Color(0xFF7F1D1D), // Red 900
    onErrorContainer: Color(0xFFFEE2E2), // Slate 100
    surface: Color(0xFF1E293B), // Slate 800
    onSurface: Color(0xFFF1F5F9), // Slate 100
    surfaceContainerHighest: Color(0xFF334155), // Slate 700
    onSurfaceVariant: Color(0xFFCBD5E1), // Slate 300

    outline: Color(0xFF64748B), // Slate 500
    outlineVariant: Color(0xFF475569), // Slate 600
    shadow: Color(0xFF000000), // Black
    scrim: Color(0xFF000000), // Black
    inverseSurface: Color(0xFFF1F5F9), // Slate 100
    onInverseSurface: Color(0xFF1E293B), // Slate 800
    inversePrimary: Color(0xFF2563EB), // Blue 600
  );

  // Additional Semantic Colors
  static const Color success = Color(0xFF10B981); // Green 500
  static const Color onSuccess = Color(0xFFFFFFFF); // White
  static const Color successDark = Color(0xFF34D399); // Green 400
  static const Color onSuccessDark = Color(0xFF065F46); // Green 800

  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color onWarning = Color(0xFFFFFFFF); // White
  static const Color warningDark = Color(0xFFFBBF24); // Amber 400
  static const Color onWarningDark = Color(0xFF92400E); // Amber 800
}

