import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/preferences_api_service.dart';

final preferencesApiServiceProvider =
    Provider<PreferencesApiService>((ref) {
  return PreferencesApiService();
});

class PreferencesState {
  final bool isLoading;
  final String? error;
  final UserPreferences? preferences;

  PreferencesState({
    this.isLoading = false,
    this.error,
    this.preferences,
  });

  PreferencesState copyWith({
    bool? isLoading,
    String? error,
    UserPreferences? preferences,
  }) {
    return PreferencesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      preferences: preferences ?? this.preferences,
    );
  }
}

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  final PreferencesApiService _preferencesApiService;

  PreferencesNotifier(this._preferencesApiService) : super(PreferencesState()) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _preferencesApiService.getPreferences();

    if (response.success && response.data != null) {
      state = state.copyWith(
        isLoading: false,
        preferences: response.data,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to load preferences',
        preferences: UserPreferences(), // Use defaults
      );
    }
  }

  Future<bool> updatePreferences({
    String? defaultSourceLanguage,
    String? defaultTargetLanguage,
    String? theme,
    bool? enableNotifications,
    bool? enableLocationTracking,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _preferencesApiService.updatePreferences(
      defaultSourceLanguage: defaultSourceLanguage,
      defaultTargetLanguage: defaultTargetLanguage,
      theme: theme,
      enableNotifications: enableNotifications,
          // enableLocationTracking: // TODO: Add to UserPreferences model enableLocationTracking,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        isLoading: false,
        preferences: response.data,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to update preferences',
      );
      return false;
    }
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>((ref) {
  final preferencesApiService = ref.watch(preferencesApiServiceProvider);
  return PreferencesNotifier(preferencesApiService);
});

