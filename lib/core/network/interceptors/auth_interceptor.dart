import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_endpoints.dart';

/// Interceptor that adds user ID to requests for device-based auth
class AuthInterceptor extends Interceptor {
  static const String _userIdKey = 'polyglot_user_id';
  String? _cachedUserId;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Load user ID from SharedPreferences if not cached
    if (_cachedUserId == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        _cachedUserId = prefs.getString(_userIdKey);
        AppLogger.d('AuthInterceptor: Loaded userId from prefs: $_cachedUserId');
      } catch (e) {
        AppLogger.e('AuthInterceptor: Failed to load userId: $e');
      }
    }

    // Add user ID header
    if (_cachedUserId != null && _cachedUserId!.isNotEmpty) {
      options.headers['X-User-Id'] = _cachedUserId;
      AppLogger.d('AuthInterceptor: Added X-User-Id header');
    } else {
      AppLogger.w('AuthInterceptor: No userId available for request to ${options.path}');
    }

    handler.next(options);
  }
  
  /// Update the cached user ID (call after registration)
  void updateUserId(String? userId) {
    _cachedUserId = userId;
    AppLogger.d('AuthInterceptor: Updated cached userId: $userId');
  }
  
  /// Clear cached user ID (for logout)
  void clearUserId() {
    _cachedUserId = null;
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // Log 401 errors for debugging
    if (err.response?.statusCode == 401) {
      AppLogger.e('AuthInterceptor: 401 Unauthorized - userId might be missing or invalid');
    }
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
