import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // History storage
  static Future<void> saveHistoryItem(String key, Map<String, dynamic> data) async {
    final history = getHistory();
    history[key] = data;
    await prefs.setString(AppConstants.storageKeyHistory, jsonEncode(history));
  }

  static Map<String, dynamic> getHistory() {
    final historyJson = prefs.getString(AppConstants.storageKeyHistory);
    if (historyJson != null) {
      return Map<String, dynamic>.from(jsonDecode(historyJson));
    }
    return {};
  }

  static Future<void> clearHistory() async {
    await prefs.remove(AppConstants.storageKeyHistory);
  }

  // Preferences storage
  static Future<void> savePreference(String key, dynamic value) async {
    final prefs = StorageService.prefs;
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  static T? getPreference<T>(String key) {
    final prefs = StorageService.prefs;
    if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == bool) {
      return prefs.getBool(key) as T?;
    } else if (T == double) {
      return prefs.getDouble(key) as T?;
    }
    return null;
  }

  // Language preferences
  static Future<void> saveLastSourceLanguage(String languageCode) async {
    await savePreference(AppConstants.storageKeyLastLanguage, languageCode);
  }

  static String? getLastSourceLanguage() {
    return getPreference<String>(AppConstants.storageKeyLastLanguage);
  }

  static Future<void> saveLastTargetLanguage(String languageCode) async {
    await savePreference(AppConstants.storageKeyLastTargetLanguage, languageCode);
  }

  static String? getLastTargetLanguage() {
    return getPreference<String>(AppConstants.storageKeyLastTargetLanguage);
  }

  // Generic string storage (for tokens)
  static Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  static Future<void> remove(String key) async {
    await prefs.remove(key);
  }

  // Generic object storage (for User, etc.)
  static Future<void> setObject(String key, Map<String, dynamic> value) async {
    await prefs.setString(key, jsonEncode(value));
  }

  static dynamic getObject(String key) {
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }
}

