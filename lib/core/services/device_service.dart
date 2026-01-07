import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// User data returned from the backend
class User {
  final String id;
  final String? deviceModel;
  final String? deviceBrand;
  final String? osName;
  final String? osVersion;
  final String? appVersion;
  final String? country;
  final String? countryCode;
  final String? city;
  final String? region;
  final String? timezone;
  final String? preferredSourceLanguage;
  final String? preferredTargetLanguage;
  final DateTime? lastActiveAt;
  final DateTime createdAt;

  const User({
    required this.id,
    this.deviceModel,
    this.deviceBrand,
    this.osName,
    this.osVersion,
    this.appVersion,
    this.country,
    this.countryCode,
    this.city,
    this.region,
    this.timezone,
    this.preferredSourceLanguage,
    this.preferredTargetLanguage,
    this.lastActiveAt,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      deviceModel: json['deviceModel'] as String?,
      deviceBrand: json['deviceBrand'] as String?,
      osName: json['osName'] as String?,
      osVersion: json['osVersion'] as String?,
      appVersion: json['appVersion'] as String?,
      country: json['country'] as String?,
      countryCode: json['countryCode'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      timezone: json['timezone'] as String?,
      preferredSourceLanguage: json['preferredSourceLanguage'] as String?,
      preferredTargetLanguage: json['preferredTargetLanguage'] as String?,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Device information collected from the device
class DeviceInfo {
  final String deviceId;
  final String? deviceModel;
  final String? deviceBrand;
  final String osName;
  final String? osVersion;
  final String? appVersion;
  final String? timezone;

  const DeviceInfo({
    required this.deviceId,
    this.deviceModel,
    this.deviceBrand,
    required this.osName,
    this.osVersion,
    this.appVersion,
    this.timezone,
  });

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        if (deviceModel != null) 'deviceModel': deviceModel,
        if (deviceBrand != null) 'deviceBrand': deviceBrand,
        'osName': osName,
        if (osVersion != null) 'osVersion': osVersion,
        if (appVersion != null) 'appVersion': appVersion,
        if (timezone != null) 'timezone': timezone,
      };
}

/// Service to collect device information and manage device identity
class DeviceService {
  static const String _deviceIdKey = 'polyglot_device_id';
  static const String _userIdKey = 'polyglot_user_id';
  static const String _userDataKey = 'polyglot_user_data';

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  
  /// Get app version from package info
  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      AppLogger.w('Failed to get app version: $e');
      return 'unknown';
    }
  }

  /// Get or create a persistent device ID
  /// IMPORTANT: Always try platform ID first since it survives app reinstalls on real devices
  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ALWAYS try platform-specific ID first (survives reinstalls on real devices)
    final platformId = await _getPlatformDeviceId();
    
    if (platformId != null && platformId.isNotEmpty) {
      // Use platform ID - save it to prefs for consistency
      await prefs.setString(_deviceIdKey, platformId);
      AppLogger.d('Using platform device ID: ${platformId.substring(0, 8)}...');
      return platformId;
    }
    
    // Fall back to cached ID or generate new UUID
    String? deviceId = prefs.getString(_deviceIdKey);
    
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
      AppLogger.d('Generated new device ID: ${deviceId.substring(0, 8)}...');
    } else {
      AppLogger.d('Using cached device ID: ${deviceId.substring(0, 8)}...');
    }
    
    return deviceId;
  }

  /// Get platform-specific device ID
  Future<String?> _getPlatformDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        // Use Android ID which is unique per app per device
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        // Use identifierForVendor which is unique per vendor per device
        return iosInfo.identifierForVendor;
      }
    } catch (e) {
      AppLogger.d('Error getting platform device ID: $e');
    }
    return null;
  }

  /// Collect comprehensive device information
  Future<DeviceInfo> collectDeviceInfo() async {
    final deviceId = await getOrCreateDeviceId();
    final timezone = DateTime.now().timeZoneName;
    final appVersion = await _getAppVersion();
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return DeviceInfo(
          deviceId: deviceId,
          deviceModel: androidInfo.model,
          deviceBrand: androidInfo.brand,
          osName: 'Android',
          osVersion: androidInfo.version.release,
          appVersion: appVersion,
          timezone: timezone,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return DeviceInfo(
          deviceId: deviceId,
          deviceModel: iosInfo.utsname.machine,
          deviceBrand: 'Apple',
          osName: 'iOS',
          osVersion: iosInfo.systemVersion,
          appVersion: appVersion,
          timezone: timezone,
        );
      }
    } catch (e) {
      AppLogger.d('Error collecting device info: $e');
    }
    
    // Fallback
    return DeviceInfo(
      deviceId: deviceId,
      osName: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      appVersion: appVersion,
      timezone: timezone,
    );
  }

  /// Save user ID locally for quick access
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  /// Get cached user ID
  Future<String?> getCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Clear user data (for testing/logout)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userDataKey);
    // Keep device ID - it's tied to the device, not the session
  }
}

final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService();
});

