import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class UserApiService {
  final Dio _dio = apiClient.dio;

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

  Future<ApiResponse<User>> updateProfile({
    String? email,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.userMe,
        data: {
          if (email != null) 'email': email,
        },
      );

      final user = User.fromJson(response.data['data'] as Map<String, dynamic>);
      
      // Update stored user
      final authService = AuthService();
      await authService.storeUser(user);

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

