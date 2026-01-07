import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';

class FeedbackSubmission {
  final String id;
  final String type; // 'bug', 'feature', 'improvement', 'general'
  final String message;
  final int? rating; // 1-5 stars
  final String? interactionId;
  final DateTime createdAt;

  FeedbackSubmission({
    required this.id,
    required this.type,
    required this.message,
    this.rating,
    this.interactionId,
    required this.createdAt,
  });

  factory FeedbackSubmission.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return FeedbackSubmission(
      id: data['feedbackId'] as String,
      type: data['type'] as String,
      message: data['message'] as String,
      rating: data['rating'] as int?,
      interactionId: data['interactionId'] as String?,
      createdAt: DateTime.parse(data['createdAt'] as String),
    );
  }
}

class FeedbackApiService {
  final Dio _dio = apiClient.dio;

  Future<ApiResponse<FeedbackSubmission>> submitFeedback({
    required String type, // 'bug', 'feature', 'improvement', 'general'
    required String message,
    int? rating, // 1-5 stars
    String? interactionId,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.feedback,
        data: {
          'type': type,
          'message': message,
          if (rating != null) 'rating': rating,
          if (interactionId != null) 'interactionId': interactionId,
        },
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => FeedbackSubmission.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to submit feedback',
      );
    }
  }
}

