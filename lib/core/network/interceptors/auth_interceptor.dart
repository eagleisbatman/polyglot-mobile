import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_endpoints.dart';

/// Interceptor that adds user ID to requests for device-based auth
class AuthInterceptor extends Interceptor {
  static const String _userIdKey = 'polyglot_user_id';
  String? _cachedUserId;
  bool _initialized = false;

  /// Initialize the interceptor by loading the user ID
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedUserId = prefs.getString(_userIdKey);
      _initialized = true;
    } catch (e) {
      AppLogger.d('AuthInterceptor: Failed to initialize: $e');
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Use cached user ID (sync) - initialized on app start
    if (_cachedUserId != null && _cachedUserId!.isNotEmpty) {
      options.headers['X-User-ID'] = _cachedUserId;
    }

    handler.next(options);
  }
  
  /// Update the cached user ID (call after login/registration)
  void updateUserId(String? userId) {
    _cachedUserId = userId;
    _initialized = true;
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
