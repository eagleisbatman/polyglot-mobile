class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Polyglot';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // File Size Limits
  static const int maxImageSizeMB = 10;
  static const int maxDocumentSizeMB = 20;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;
  static const int maxDocumentSizeBytes = maxDocumentSizeMB * 1024 * 1024;

  // Audio Configuration
  static const int audioSampleRate = 16000;
  static const int audioChannels = 1; // Mono

  // Session Configuration
  static const Duration sessionTimeout = Duration(minutes: 5);
  static const Duration idleTimeout = Duration(minutes: 5);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 16.0;
  static const double minTouchTargetSize = 44.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Storage Keys
  static const String storageKeyHistory = 'translation_history';
  static const String storageKeyPreferences = 'user_preferences';
  static const String storageKeyLastLanguage = 'last_source_language';
  static const String storageKeyLastTargetLanguage = 'last_target_language';
}

