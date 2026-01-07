import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../features/chat/domain/entities/chat_message.dart';
import 'history_storage_service.dart';

/// Service for syncing history with the backend
class HistorySyncService {
  final Dio _dio;
  final HistoryStorageService _localStorage;
  
  HistorySyncService({Dio? dio, HistoryStorageService? localStorage})
      : _dio = dio ?? Dio(),
        _localStorage = localStorage ?? HistoryStorageService() {
    _dio.options.baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Fetch history from backend
  Future<List<ChatMessage>> fetchHistory({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type,
      };

      final response = await _dio.get(
        '/api/v1/history',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final items = response.data['data']['items'] as List<dynamic>;
        return items.map((item) => _mapToMessage(item)).toList();
      }
      
      return [];
    } catch (e) {
      AppLogger.d('Error fetching history: $e');
      // Fall back to local storage
      return _localStorage.getHistory();
    }
  }

  /// Get a single interaction by ID
  Future<ChatMessage?> getInteraction(String id) async {
    try {
      final response = await _dio.get('/api/v1/history/$id');

      if (response.data['success'] == true) {
        return _mapToMessage(response.data['data']);
      }
      
      return null;
    } catch (e) {
      AppLogger.d('Error fetching interaction: $e');
      return _localStorage.getMessage(id);
    }
  }

  /// Delete an interaction
  Future<bool> deleteInteraction(String id) async {
    try {
      final response = await _dio.delete('/api/v1/history/$id');
      
      if (response.data['success'] == true) {
        // Also delete from local storage
        await _localStorage.deleteMessage(id);
        return true;
      }
      
      return false;
    } catch (e) {
      AppLogger.d('Error deleting interaction: $e');
      return false;
    }
  }

  /// Upload audio file to backend
  Future<String?> uploadAudio({
    required String filePath,
    String? interactionId,
    String type = 'user', // 'user' or 'translation'
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppLogger.d('Audio file not found: $filePath');
        return null;
      }

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        if (interactionId != null) 'interactionId': interactionId,
        'type': type,
      });

      final response = await _dio.post(
        '/api/v1/audio/upload',
        data: formData,
      );

      if (response.data['success'] == true) {
        return response.data['data']['url'] as String?;
      }
      
      return null;
    } catch (e) {
      AppLogger.d('Error uploading audio: $e');
      return null;
    }
  }

  /// Upload audio as base64
  Future<String?> uploadAudioBase64({
    required String base64Audio,
    String? interactionId,
    String type = 'user',
    String mimeType = 'audio/wav',
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/audio/upload-base64',
        data: {
          'audio': base64Audio,
          if (interactionId != null) 'interactionId': interactionId,
          'type': type,
          'mimeType': mimeType,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data']['url'] as String?;
      }
      
      return null;
    } catch (e) {
      AppLogger.d('Error uploading audio: $e');
      return null;
    }
  }

  /// Get full audio URL from relative path
  String getFullAudioUrl(String relativePath) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    if (relativePath.startsWith('http')) {
      return relativePath;
    }
    return '$baseUrl$relativePath';
  }

  /// Sync local history to backend
  Future<void> syncLocalToBackend() async {
    try {
      final localHistory = await _localStorage.getHistory();
      
      for (final message in localHistory) {
        // Upload audio files if they exist locally but not on server
        if (message.userAudioPath != null && 
            !message.userAudioPath!.startsWith('http')) {
          final audioUrl = await uploadAudio(
            filePath: message.userAudioPath!,
            type: 'user',
          );
          
          if (audioUrl != null) {
            // Update local storage with new URL
            await _localStorage.saveMessage(
              message.copyWith(userAudioPath: audioUrl),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.d('Error syncing to backend: $e');
    }
  }

  /// Map backend response to ChatMessage
  ChatMessage _mapToMessage(Map<String, dynamic> data) {
    MessageType type;
    switch (data['type']) {
      case 'voice':
        type = MessageType.voice;
        break;
      case 'vision':
        type = MessageType.vision;
        break;
      case 'document':
        type = MessageType.document;
        break;
      default:
        type = MessageType.text;
    }

    return ChatMessage(
      id: data['id'] as String,
      type: type,
      status: MessageStatus.complete,
      userContent: data['transcription'] as String? ?? 
                   data['extractedText'] as String? ?? 
                   data['originalText'] as String?,
      translatedContent: data['translation'] as String? ?? 
                         data['translatedText'] as String? ?? 
                         data['resultText'] as String?,
      userAudioPath: data['userAudioUrl'] as String?,
      translationAudioPath: data['translationAudioUrl'] as String?,
      imageUrl: data['imageUrl'] as String?,
      documentName: data['fileName'] as String?,
      sourceLanguage: data['sourceLanguage'] as String? ?? 'en',
      targetLanguage: data['targetLanguage'] as String? ?? 'hi',
      timestamp: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

