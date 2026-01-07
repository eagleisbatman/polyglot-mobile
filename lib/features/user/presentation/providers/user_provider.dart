import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/device_service.dart';

/// Provider for user profile state
/// Uses the auth provider for user data since we use device-based auth
final userProfileProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// Provider to check if user profile is loading
final userProfileLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.loading;
});

/// Provider to get any auth errors
final userProfileErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.error;
});

/// Refresh user profile from backend
Future<void> refreshUserProfile(WidgetRef ref) async {
  await ref.read(authProvider.notifier).initialize();
}

/// Update user language preferences
Future<void> updateUserPreferences(
  WidgetRef ref, {
  String? sourceLanguage,
  String? targetLanguage,
}) async {
  await ref.read(authProvider.notifier).updatePreferences(
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
  );
}

/// Update user location
Future<void> updateUserLocation(
  WidgetRef ref, {
  String? country,
  String? countryCode,
  String? city,
  String? region,
  String? latitude,
  String? longitude,
  String? timezone,
}) async {
  await ref.read(authProvider.notifier).updateLocation(
    country: country,
    countryCode: countryCode,
    city: city,
    region: region,
    latitude: latitude,
    longitude: longitude,
    timezone: timezone,
  );
}
