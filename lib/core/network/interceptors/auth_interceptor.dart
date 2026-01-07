import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_endpoints.dart';

/// Interceptor that adds user ID to requests for device-based auth
class AuthInterceptor extends Interceptor {
  static const String _userIdKey = 'polyglot_user_id';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Add user ID header for device-based auth
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      
      if (userId != null && userId.isNotEmpty) {
        options.headers['X-User-ID'] = userId;
      }
    } catch (e) {
      // Failed to get user ID, continue without it
      AppLogger.d('AuthInterceptor: Failed to get user ID: $e');
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // For device-based auth, we just pass through errors
    // No token refresh needed
    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    final publicPaths = [
      ApiEndpoints.health,
      ApiEndpoints.languages,
      '/api/v1/device/register', // Device registration is public
    ];
    return publicPaths.any((p) => path.contains(p));
  }
}
