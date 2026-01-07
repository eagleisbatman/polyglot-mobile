import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';
import 'device_service.dart'; // User model is in device_service

/// Service for user-related API calls
/// Note: With device-based auth, most user operations are handled by AuthService.
/// This service is kept for backwards compatibility but may be deprecated.
class UserApiService {
  final Dio _dio = apiClient.dio;

  /// Get current user profile from backend
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiEndpoints.userMe);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => User.fromJson(json['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch user profile',
      );
    }
  }

  /// Update user profile
  /// Note: For device-based auth, prefer using AuthService.updatePreferences()
  Future<ApiResponse<User>> updateProfile({
    String? preferredSourceLanguage,
    String? preferredTargetLanguage,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.userMe,
        data: {
          if (preferredSourceLanguage != null) 
            'preferredSourceLanguage': preferredSourceLanguage,
          if (preferredTargetLanguage != null) 
            'preferredTargetLanguage': preferredTargetLanguage,
        },
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => User.fromJson(json['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to update profile',
      );
    }
  }
}

