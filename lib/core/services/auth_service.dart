import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';
import '../services/storage_service.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponse(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}

class User {
  final String id;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class AuthService {
  final Dio _dio = apiClient.dio;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';

  Future<ApiResponse<AuthResponse>> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authRegister,
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Store tokens and user
      await _storeTokens(authResponse.accessToken, authResponse.refreshToken);
      await _storeUser(authResponse.user);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Registration failed. Please try again.',
      );
    }
  }

  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Store tokens and user
      await _storeTokens(authResponse.accessToken, authResponse.refreshToken);
      await _storeUser(authResponse.user);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Login failed. Please check your credentials.',
      );
    }
  }

  Future<ApiResponse<AuthResponse>> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse(
        success: false,
        error: 'No refresh token available',
      );
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.authRefresh,
        data: {
          'refreshToken': refreshToken,
        },
      );

      final authResponse = AuthResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );

      // Update stored tokens
      await _storeTokens(authResponse.accessToken, authResponse.refreshToken);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      // If refresh fails, clear tokens
      await logout();
      return ApiResponse(
        success: false,
        error: 'Session expired. Please login again.',
      );
    }
  }

  Future<void> logout() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        await _dio.post(
          ApiEndpoints.authLogout,
          options: Options(
            headers: {'Authorization': 'Bearer $accessToken'},
          ),
        );
      }
    } catch (e) {
      // Ignore errors during logout
    } finally {
      // Always clear local storage
      await StorageService.remove(_accessTokenKey);
      await StorageService.remove(_refreshTokenKey);
      await StorageService.remove(_userKey);
    }
  }

  Future<String?> getAccessToken() async {
    return await StorageService.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await StorageService.getString(_refreshTokenKey);
  }

  Future<User?> getCurrentUser() async {
    try {
      final userData = await StorageService.getObject(_userKey);
      if (userData == null) return null;
      
      final json = Map<String, dynamic>.from(userData as Map);
      return User.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    await StorageService.setString(_accessTokenKey, accessToken);
    await StorageService.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> _storeUser(User user) async {
    await StorageService.setObject(_userKey, user.toJson());
  }

  // Expose _storeUser for UserApiService
  Future<void> storeUser(User user) async {
    await _storeUser(user);
  }
}

