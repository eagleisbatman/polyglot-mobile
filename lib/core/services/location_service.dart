import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../constants/supported_languages.dart';

class LocationService {
  Future<String?> getCurrentLanguageCode() async {
    try {
      final position = await _getCurrentPosition();
      if (position != null) {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final countryCode = placemarks.first.isoCountryCode?.toLowerCase();
          return _countryCodeToLanguageCode(countryCode);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
    } catch (e) {
      return null;
    }
  }

  String? _countryCodeToLanguageCode(String? countryCode) {
    if (countryCode == null) return null;

    // Map common country codes to language codes
    final countryToLanguage = {
      'us': 'en',
      'gb': 'en',
      'in': 'hi',
      'es': 'es',
      'mx': 'es',
      'fr': 'fr',
      'de': 'de',
      'cn': 'zh',
      'tw': 'zh',
      'jp': 'ja',
      'kr': 'ko',
      'br': 'pt',
      'pt': 'pt',
      'it': 'it',
      'ru': 'ru',
      'sa': 'ar',
      'ae': 'ar',
      'vn': 'vi',
      'th': 'th',
    };

    return countryToLanguage[countryCode.toLowerCase()];
  }

  Future<bool> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }
}

