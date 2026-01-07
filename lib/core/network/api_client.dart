import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;

  ApiClient() {
    _authInterceptor = AuthInterceptor();
    
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? '',
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        sendTimeout: AppConstants.apiTimeout, // For uploading large audio files
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor, // Add user ID to requests (device-based auth)
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;
  
  /// Update the cached user ID in the auth interceptor
  void updateUserId(String? userId) {
    _authInterceptor.updateUserId(userId);
  }

  bool get isConfigured => (dotenv.env['API_BASE_URL']?.isNotEmpty ?? false);
}

// Global instance
final apiClient = ApiClient();
