import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await StorageService.init();
      authService = AuthService();
    });

    tearDown(() async {
      await StorageService.remove('access_token');
      await StorageService.remove('refresh_token');
      await StorageService.remove('user');
    });

    test('should return false when not authenticated', () async {
      final isAuthenticated = await authService.isAuthenticated();
      expect(isAuthenticated, false);
    });

    test('should store and retrieve access token', () async {
      await StorageService.setString('access_token', 'test_token');
      final token = await authService.getAccessToken();
      expect(token, 'test_token');
    });

    test('should store and retrieve refresh token', () async {
      await StorageService.setString('refresh_token', 'test_refresh');
      final token = await authService.getRefreshToken();
      expect(token, 'test_refresh');
    });

    test('should clear tokens after logout', () async {
      await StorageService.setString('access_token', 'test_token');
      await StorageService.setString('refresh_token', 'test_refresh');
      
      await authService.logout();
      
      final accessToken = await authService.getAccessToken();
      final refreshToken = await authService.getRefreshToken();
      
      expect(accessToken, isNull);
      expect(refreshToken, isNull);
    });

    test('should return null for user when not stored', () async {
      final user = await authService.getCurrentUser();
      expect(user, isNull);
    });
  });
}

