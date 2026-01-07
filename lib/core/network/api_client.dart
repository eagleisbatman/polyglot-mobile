import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  final BuildContext? _context;

  ApiClient({BuildContext? context}) : _context = context {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? '',
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(_context), // Add auth token to requests
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  bool get isConfigured => (dotenv.env['API_BASE_URL']?.isNotEmpty ?? false);
  
  // Update context for auth interceptor
  void updateContext(BuildContext? context) {
    // Note: This is a simplified approach
    // In production, you might want to recreate the interceptor or use a different pattern
  }
}

// Global instance - will be initialized with context from app
final apiClient = ApiClient();
