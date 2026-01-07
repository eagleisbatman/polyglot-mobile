import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/user_api_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/network/models/api_response.dart';

// Match the bypass flag from app.dart
const bool _kBypassAuth = kDebugMode;

final userApiServiceProvider = Provider<UserApiService>((ref) {
  return UserApiService();
});

class UserProfileState {
  final bool isLoading;
  final String? error;
  final User? user;

  UserProfileState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  UserProfileState copyWith({
    bool? isLoading,
    String? error,
    User? user,
  }) {
    return UserProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserApiService _userApiService;
  final AuthService _authService;

  UserProfileNotifier(this._userApiService, this._authService)
      : super(UserProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    // In debug mode with auth bypass, show mock user
    if (_kBypassAuth) {
      state = state.copyWith(
        isLoading: false,
        user: User(
          id: 'dev-user-123',
          email: 'developer@polyglot.app',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        error: null,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final response = await _userApiService.getCurrentUser();

    if (response.success && response.data != null) {
      state = state.copyWith(
        isLoading: false,
        user: response.data,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to load profile',
      );
    }
  }

  Future<bool> updateProfile({String? email}) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _userApiService.updateProfile(email: email);

    if (response.success && response.data != null) {
      state = state.copyWith(
        isLoading: false,
        user: response.data,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to update profile',
      );
      return false;
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final userApiService = ref.watch(userApiServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return UserProfileNotifier(userApiService, authService);
});

