import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';

class UserPreferences {
  final String? defaultSourceLanguage;
  final String? defaultTargetLanguage;
  final String? preferredVoice;
  final bool autoDetectLanguage;
  final bool enableNotifications;
  final String theme; // 'light', 'dark', 'system'
  final Map<String, dynamic>? metadata;

  UserPreferences({
    this.defaultSourceLanguage,
    this.defaultTargetLanguage,
    this.preferredVoice,
    this.autoDetectLanguage = true,
    this.enableNotifications = true,
    this.theme = 'system',
    this.metadata,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      defaultSourceLanguage: json['defaultSourceLanguage'] as String?,
      defaultTargetLanguage: json['defaultTargetLanguage'] as String?,
      preferredVoice: json['preferredVoice'] as String?,
      autoDetectLanguage: json['autoDetectLanguage'] as bool? ?? true,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'system',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (defaultSourceLanguage != null)
        'defaultSourceLanguage': defaultSourceLanguage,
      if (defaultTargetLanguage != null)
        'defaultTargetLanguage': defaultTargetLanguage,
      if (preferredVoice != null) 'preferredVoice': preferredVoice,
      'autoDetectLanguage': autoDetectLanguage,
      'enableNotifications': enableNotifications,
      'theme': theme,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class PreferencesApiService {
  final Dio _dio = apiClient.dio;

  Future<ApiResponse<UserPreferences>> getPreferences() async {
    try {
      final response = await _dio.get(ApiEndpoints.preferences);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserPreferences.fromJson(json['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Return default preferences if not found
        return ApiResponse(
          success: true,
          data: UserPreferences(),
        );
      }
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch preferences',
      );
    }
  }

  Future<ApiResponse<UserPreferences>> updatePreferences({
    String? defaultSourceLanguage,
    String? defaultTargetLanguage,
    String? preferredVoice,
    bool? autoDetectLanguage,
    bool? enableNotifications,
    String? theme,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.preferences,
        data: {
          if (defaultSourceLanguage != null)
            'defaultSourceLanguage': defaultSourceLanguage,
          if (defaultTargetLanguage != null)
            'defaultTargetLanguage': defaultTargetLanguage,
          if (preferredVoice != null) 'preferredVoice': preferredVoice,
          if (autoDetectLanguage != null)
            'autoDetectLanguage': autoDetectLanguage,
          if (enableNotifications != null)
            'enableNotifications': enableNotifications,
          if (theme != null) 'theme': theme,
          if (metadata != null) 'metadata': metadata,
        },
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserPreferences.fromJson(json['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to update preferences',
      );
    }
  }
}

