import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';

/// A single message within a conversation
class HistoryMessage {
  final String id;
  final String type; // 'voice', 'vision', 'document'
  final String? sourceLanguage;
  final String targetLanguage;
  final DateTime createdAt;
  
  // Voice session data
  final String? transcription;
  final String? translation;
  final String? summary;
  final String? userAudioUrl;
  final String? translationAudioUrl;
  
  // Vision data
  final String? imageUrl;
  final String? extractedText;
  
  // Document data
  final String? documentName;

  HistoryMessage({
    required this.id,
    required this.type,
    this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
    this.transcription,
    this.translation,
    this.summary,
    this.userAudioUrl,
    this.translationAudioUrl,
    this.imageUrl,
    this.extractedText,
    this.documentName,
  });

  factory HistoryMessage.fromJson(Map<String, dynamic> json) {
    return HistoryMessage(
      id: json['id'] as String,
      type: json['type'] as String,
      sourceLanguage: json['sourceLanguage'] as String?,
      targetLanguage: json['targetLanguage'] as String? ?? 'en',
      createdAt: DateTime.parse(json['createdAt'] as String),
      transcription: json['transcription'] as String?,
      translation: json['translation'] as String?,
      summary: json['sessionSummary'] as String? ?? json['summary'] as String?,
      userAudioUrl: json['userAudioUrl'] as String?,
      translationAudioUrl: json['translationAudioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      extractedText: json['extractedText'] as String?,
      documentName: json['fileName'] as String? ?? json['documentName'] as String?,
    );
  }
}

/// A conversation containing multiple messages
class Conversation {
  final String id;
  final String title;
  final String? sourceLanguage;
  final String targetLanguage;
  final int messageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HistoryMessage? preview; // First message preview

  Conversation({
    required this.id,
    required this.title,
    this.sourceLanguage,
    required this.targetLanguage,
    required this.messageCount,
    required this.createdAt,
    required this.updatedAt,
    this.preview,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled',
      sourceLanguage: json['sourceLanguage'] as String?,
      targetLanguage: json['targetLanguage'] as String? ?? 'en',
      messageCount: json['messageCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      preview: json['preview'] != null 
          ? HistoryMessage.fromJson(json['preview'] as Map<String, dynamic>)
          : null,
    );
  }
  
  /// Get display title (from preview if available)
  String get displayTitle {
    if (title.isNotEmpty && title != 'Untitled') return title;
    final text = preview?.transcription ?? preview?.summary ?? preview?.extractedText;
    if (text == null || text.isEmpty) return 'Untitled';
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }
  
  /// Get display subtitle (translation, truncated)
  String? get displaySubtitle {
    final translation = preview?.translation;
    if (translation == null || translation.isEmpty) return null;
    return translation.length > 80 
        ? '${translation.substring(0, 80)}...' 
        : translation;
  }
}

class ConversationListResponse {
  final List<Conversation> items;
  final int total;
  final int limit;
  final int page;

  ConversationListResponse({
    required this.items,
    required this.total,
    required this.limit,
    required this.page,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>?;
    
    return ConversationListResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: _parseIntSafe(pagination?['total']),
      limit: _parseIntSafe(pagination?['limit']) ?? 20,
      page: _parseIntSafe(pagination?['page']) ?? 1,
    );
  }
  
  static int _parseIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class ConversationDetailResponse {
  final Conversation conversation;
  final List<HistoryMessage> messages;

  ConversationDetailResponse({
    required this.conversation,
    required this.messages,
  });

  factory ConversationDetailResponse.fromJson(Map<String, dynamic> json) {
    final convJson = json['conversation'] as Map<String, dynamic>;
    return ConversationDetailResponse(
      conversation: Conversation.fromJson(convJson),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((item) => HistoryMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HistoryApiService {
  final Dio _dio = apiClient.dio;

  /// Get paginated list of conversations
  Future<ApiResponse<ConversationListResponse>> getConversations({
    String type = 'all', // 'all', 'voice', 'vision', 'document'
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.history,
        queryParameters: {
          'type': type,
          'page': page,
          'limit': limit,
        },
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ConversationListResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch conversations',
      );
    }
  }

  /// Get all messages in a conversation
  Future<ApiResponse<ConversationDetailResponse>> getConversationMessages(String conversationId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.history}/conversations/$conversationId');

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ConversationDetailResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch conversation messages',
      );
    }
  }

  /// Delete a conversation (soft delete)
  Future<ApiResponse<void>> deleteConversation(String id) async {
    try {
      await _dio.delete(ApiEndpoints.historyItem(id));

      return ApiResponse(
        success: true,
        data: null,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to delete conversation',
      );
    }
  }
}
