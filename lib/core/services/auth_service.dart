import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_service.dart';

/// Authentication state for the app
enum AuthStatus { 
  initial,       // App just started
  loading,       // Registering device
  onboarding,    // New user needs onboarding
  authenticated, // User is authenticated (onboarding complete)
  error,         // Authentication failed
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isNewUser;
  final bool onboardingComplete;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isNewUser = false,
    this.onboardingComplete = false,
  });

  /// Copy with optional overrides
  /// Set [clearError] to true to explicitly clear the error
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool clearError = false,
    bool? isNewUser,
    bool? onboardingComplete,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      isNewUser: isNewUser ?? this.isNewUser,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

/// Service for device-based authentication
class AuthService {
  final DeviceService _deviceService;
  final Dio _dio;

  AuthService(this._deviceService, {Dio? dio}) 
      : _dio = dio ?? Dio() {
    _dio.options.baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Register device and get/create user
  Future<AuthState> registerDevice() async {
    try {
      // Collect device information
      final deviceInfo = await _deviceService.collectDeviceInfo();
      
      // Register with backend
      final response = await _dio.post(
        '/api/v1/device/register',
        data: deviceInfo.toJson(),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final user = User.fromJson(data['user']);
        final isNewUser = data['isNewUser'] as bool;
        
        // Save user ID locally
        await _deviceService.saveUserId(user.id);
        
        return AuthState(
          status: AuthStatus.authenticated,
          user: user,
          isNewUser: isNewUser,
        );
      }
      
      return const AuthState(
        status: AuthStatus.error,
        error: 'Registration failed',
      );
    } on DioException catch (e) {
      AppLogger.d('Auth error: ${e.message}');
      return AuthState(
        status: AuthStatus.error,
        error: e.message ?? 'Network error',
      );
    } catch (e) {
      AppLogger.d('Auth error: $e');
      return AuthState(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Update user's location
  Future<User?> updateLocation({
    required String userId,
    String? country,
    String? countryCode,
    String? city,
    String? region,
    String? latitude,
    String? longitude,
    String? timezone,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/device/user/$userId/location',
        data: {
          if (country != null) 'country': country,
          if (countryCode != null) 'countryCode': countryCode,
          if (city != null) 'city': city,
          if (region != null) 'region': region,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (timezone != null) 'timezone': timezone,
        },
      );

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      AppLogger.d('Update location error: $e');
      return null;
    }
  }

  /// Update user's language preferences
  Future<User?> updatePreferences({
    required String userId,
    String? sourceLanguage,
    String? targetLanguage,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/device/user/$userId/preferences',
        data: {
          if (sourceLanguage != null) 'preferredSourceLanguage': sourceLanguage,
          if (targetLanguage != null) 'preferredTargetLanguage': targetLanguage,
        },
      );

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      AppLogger.d('Update preferences error: $e');
      return null;
    }
  }

  /// Get user by ID
  Future<User?> getUser(String userId) async {
    try {
      final response = await _dio.get('/api/v1/device/user/$userId');

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      AppLogger.d('Get user error: $e');
      return null;
    }
  }

  /// Get the current user ID
  Future<String?> getCurrentUserId() async {
    return _deviceService.getCachedUserId();
  }
}

/// Auth notifier for state management
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  static const String _onboardingKey = 'polyglot_onboarding_complete';

  AuthNotifier(this._authService) : super(const AuthState());

  /// Initialize authentication on app start
  Future<void> initialize() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    // Check if onboarding was completed before
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool(_onboardingKey) ?? false;
    
    final result = await _authService.registerDevice();
    
    if (result.status == AuthStatus.authenticated) {
      // Determine if we need to show onboarding
      final needsOnboarding = result.isNewUser && !onboardingComplete;
      
      state = result.copyWith(
        status: needsOnboarding ? AuthStatus.onboarding : AuthStatus.authenticated,
        onboardingComplete: onboardingComplete,
      );
    } else {
      state = result;
    }
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    
    state = state.copyWith(
      status: AuthStatus.authenticated,
      onboardingComplete: true,
    );
  }

  /// Update user's location
  Future<void> updateLocation({
    String? country,
    String? countryCode,
    String? city,
    String? region,
    String? latitude,
    String? longitude,
    String? timezone,
  }) async {
    if (state.user == null) return;
    
    final updatedUser = await _authService.updateLocation(
      userId: state.user!.id,
      country: country,
      countryCode: countryCode,
      city: city,
      region: region,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
    
    if (updatedUser != null) {
      state = state.copyWith(user: updatedUser);
    }
  }

  /// Update language preferences
  Future<void> updatePreferences({
    String? sourceLanguage,
    String? targetLanguage,
  }) async {
    if (state.user == null) return;
    
    final updatedUser = await _authService.updatePreferences(
      userId: state.user!.id,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
    
    if (updatedUser != null) {
      state = state.copyWith(user: updatedUser);
    }
  }

  /// Get the current user ID
  String? get userId => state.user?.id;
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return AuthService(deviceService);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
