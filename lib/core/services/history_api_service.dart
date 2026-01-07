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
  final Map<String, dynamic>? metadata;

  HistoryItem({
    required this.id,
    required this.type,
    this.sourceLanguage,
    required this.targetLanguage,
    required this.createdAt,
    this.metadata,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      type: json['type'] as String,
      sourceLanguage: json['sourceLanguage'] as String?,
      targetLanguage: json['targetLanguage'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
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
    final data = json['data'] as Map<String, dynamic>;
    return HistoryListResponse(
      items: (data['items'] as List<dynamic>)
          .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int,
      limit: data['limit'] as int,
      offset: data['offset'] as int,
    );
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

