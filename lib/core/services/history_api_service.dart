import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';

class HistoryItem {
  final String id;
  final String type; // 'voice', 'vision', 'document'
  final String? sourceLanguage;
  final String targetLanguage;
  final DateTime createdAt;
  final String? status;
  
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

  HistoryItem({
    required this.id,
    required this.type,
    this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
    this.status,
    this.transcription,
    this.translation,
    this.summary,
    this.userAudioUrl,
    this.translationAudioUrl,
    this.imageUrl,
    this.extractedText,
    this.documentName,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      type: json['type'] as String,
      sourceLanguage: json['sourceLanguage'] as String?,
      targetLanguage: json['targetLanguage'] as String? ?? 'en',
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String?,
      transcription: json['transcription'] as String?,
      translation: json['translation'] as String?,
      summary: json['summary'] as String?,
      userAudioUrl: json['userAudioUrl'] as String?,
      translationAudioUrl: json['translationAudioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      extractedText: json['extractedText'] as String?,
      documentName: json['documentName'] as String?,
    );
  }
  
  /// Get display title (transcription or summary, truncated)
  String get displayTitle {
    final text = transcription ?? summary ?? extractedText ?? documentName;
    if (text == null || text.isEmpty) return 'Untitled';
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }
  
  /// Get display subtitle (translation, truncated)
  String? get displaySubtitle {
    if (translation == null || translation!.isEmpty) return null;
    return translation!.length > 80 
        ? '${translation!.substring(0, 80)}...' 
        : translation;
  }
}

class HistoryListResponse {
  final List<HistoryItem> items;
  final int total;
  final int limit;
  final int offset;

  HistoryListResponse({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory HistoryListResponse.fromJson(Map<String, dynamic> json) {
    // json is already the inner data object from ApiResponse
    final pagination = json['pagination'] as Map<String, dynamic>?;
    
    return HistoryListResponse(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: _parseIntSafe(pagination?['total']),
      limit: _parseIntSafe(pagination?['limit']) ?? 50,
      offset: _parseIntSafe(pagination?['page']) ?? 0,
    );
  }
  
  /// Safely parse int from either int or string
  static int _parseIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class HistoryApiService {
  final Dio _dio = apiClient.dio;

  Future<ApiResponse<HistoryListResponse>> getHistory({
    String type = 'all', // 'all', 'voice', 'vision', 'document'
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.history,
        queryParameters: {
          'type': type,
          'limit': limit,
          'offset': offset,
        },
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => HistoryListResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch history',
      );
    }
  }

  Future<ApiResponse<HistoryItem>> getHistoryItem(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.historyItem(id));

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => HistoryItem.fromJson(json['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch history item',
      );
    }
  }

  Future<ApiResponse<void>> deleteHistoryItem(String id) async {
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
            'Failed to delete history item',
      );
    }
  }
}

