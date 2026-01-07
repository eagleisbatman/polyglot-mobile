import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/chat/domain/entities/chat_message.dart';

/// Local storage service for translation history
class HistoryStorageService {
  static const String _historyKey = 'polyglot_translation_history';
  static const int _maxHistoryItems = 100;

  /// Save a message to history
  Future<void> saveMessage(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Check if message already exists (update it)
    final existingIndex = history.indexWhere((m) => m.id == message.id);
    if (existingIndex >= 0) {
      history[existingIndex] = message;
    } else {
      // Add to beginning (most recent first)
      history.insert(0, message);
    }
    
    // Limit history size
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    final jsonList = history.map((m) => m.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  /// Get all history
  Future<List<ChatMessage>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.d('Error loading history: $e');
      return [];
    }
  }

  /// Get history filtered by type
  Future<List<ChatMessage>> getHistoryByType(MessageType type) async {
    final history = await getHistory();
    return history.where((m) => m.type == type).toList();
  }

  /// Delete a message from history
  Future<void> deleteMessage(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    history.removeWhere((m) => m.id == messageId);
    
    final jsonList = history.map((m) => m.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  /// Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  /// Get message by ID
  Future<ChatMessage?> getMessage(String messageId) async {
    final history = await getHistory();
    try {
      return history.firstWhere((m) => m.id == messageId);
    } catch (_) {
      return null;
    }
  }
}

