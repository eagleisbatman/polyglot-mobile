import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'auth_service.dart';

/// Location data with geocoded address
class LocationData {
  final double latitude;
  final double longitude;
  final String? country;
  final String? countryCode;
  final String? city;
  final String? region;
  final String? timezone;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.country,
    this.countryCode,
    this.city,
    this.region,
    this.timezone,
  });
}

/// Service for collecting and managing location data
class LocationService {
  final AuthNotifier _authNotifier;

  LocationService(this._authNotifier);

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      return result == LocationPermission.always ||
          result == LocationPermission.whileInUse;
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied, user needs to enable in settings
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Get current location and geocode it
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.d('Location services are disabled');
        return null;
      }

      // Check permission
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        AppLogger.d('Location permission not granted');
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // Low accuracy is faster
        timeLimit: const Duration(seconds: 10),
      );

      // Geocode to get address
      String? country;
      String? countryCode;
      String? city;
      String? region;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          country = place.country;
          countryCode = place.isoCountryCode;
          city = place.locality ?? place.subAdministrativeArea;
          region = place.administrativeArea;
        }
      } catch (e) {
        AppLogger.d('Geocoding failed: $e');
        // Continue without geocoded address
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        country: country,
        countryCode: countryCode,
        city: city,
        region: region,
        timezone: DateTime.now().timeZoneName,
      );
    } catch (e) {
      AppLogger.d('Failed to get location: $e');
      return null;
    }
  }

  /// Update location on the server
  Future<bool> updateLocationOnServer() async {
    final location = await getCurrentLocation();
    if (location == null) return false;

    await _authNotifier.updateLocation(
      country: location.country,
      countryCode: location.countryCode,
      city: location.city,
      region: location.region,
      latitude: location.latitude.toString(),
      longitude: location.longitude.toString(),
      timezone: location.timezone,
    );

    return true;
  }

  /// Open app settings for location permission
  Future<bool> openSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return LocationService(authNotifier);
});
