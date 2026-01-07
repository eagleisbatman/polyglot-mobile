import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';

class VoiceSession {
  final String id;
  final String interactionId;
  final String? sessionSummary;
  final String? transcription;
  final String? translation;
  final int? duration; // in seconds
  final DateTime createdAt;

  VoiceSession({
    required this.id,
    required this.interactionId,
    this.sessionSummary,
    this.transcription,
    this.translation,
    this.duration,
    required this.createdAt,
  });

  factory VoiceSession.fromJson(Map<String, dynamic> json) {
    return VoiceSession(
      id: json['id'] as String,
      interactionId: json['interactionId'] as String,
      sessionSummary: json['sessionSummary'] as String?,
      transcription: json['transcription'] as String?,
      translation: json['translation'] as String?,
      duration: json['duration'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class SessionListResponse {
  final List<VoiceSession> sessions;
  final int total;

  SessionListResponse({
    required this.sessions,
    required this.total,
  });

  factory SessionListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return SessionListResponse(
      sessions: (data['sessions'] as List<dynamic>)
          .map((item) => VoiceSession.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: data['total'] as int,
    );
  }
}

class SessionsApiService {
  final Dio _dio = apiClient.dio;

  Future<ApiResponse<SessionListResponse>> getSessions({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.sessions,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => SessionListResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch sessions',
      );
    }
  }

  Future<ApiResponse<VoiceSession>> getSession(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.sessionItem(id));

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => VoiceSession.fromJson(json['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch session',
      );
    }
  }

  Future<ApiResponse<void>> deleteSession(String id) async {
    try {
      await _dio.delete(ApiEndpoints.sessionItem(id));

      return ApiResponse(
        success: true,
        data: null,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to delete session',
      );
    }
  }
}

