class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = '/api/v1';

  // Health check
  static const String health = '/health';

  // Authentication endpoints
  static const String authRegister = '$baseUrl/auth/register';
  static const String authLogin = '$baseUrl/auth/login';
  static const String authLogout = '$baseUrl/auth/logout';
  static const String authRefresh = '$baseUrl/auth/refresh';

  // User endpoints
  static const String userMe = '$baseUrl/users/me';

  // Location endpoints
  static const String location = '$baseUrl/location';

  // Preferences endpoints
  static const String preferences = '$baseUrl/preferences';

  // Voice endpoints
  static const String voiceTranslate = '$baseUrl/voice/translate';
  static String voiceFollowUp(String interactionId) =>
      '$baseUrl/voice/interactions/$interactionId/follow-up';

  // Vision endpoints
  static const String visionTranslate = '$baseUrl/vision/translate';

  // Document endpoints
  static const String documentTranslate = '$baseUrl/documents/translate';

  // History endpoints
  static const String history = '$baseUrl/history';
  static String historyItem(String id) => '$baseUrl/history/$id';

  // Sessions endpoints
  static const String sessions = '$baseUrl/sessions';
  static String sessionItem(String id) => '$baseUrl/sessions/$id';

  // Languages endpoint
  static const String languages = '$baseUrl/languages';

  // Feedback endpoint
  static const String feedback = '$baseUrl/feedback';

  // Stats endpoints
  static const String stats = '$baseUrl/stats';
  static const String statsUsage = '$baseUrl/stats/usage';
}

