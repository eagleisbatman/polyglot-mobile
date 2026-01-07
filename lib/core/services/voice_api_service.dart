import 'package:dio/dio.dart';
import 'package:polyglot_mobile/core/utils/app_logger.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';
import '../../shared/models/voice_translation_response.dart';
import '../../shared/models/follow_up_question.dart';

class VoiceApiService {
  final Dio _dio = apiClient.dio;

  Future<ApiResponse<VoiceTranslationResponse>> translateVoice({
    required String audioBase64,
    required String sourceLanguage,
    required String targetLanguage,
    String? previousInteractionId,
    String? conversationId,
  }) async {
    // Use mock data if backend is not configured
    if (!apiClient.isConfigured) {
      return _mockVoiceTranslation(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    }

    try {
      AppLogger.d('VoiceApiService.translateVoice called with conversationId: $conversationId');
      
      final response = await _dio.post(
        ApiEndpoints.voiceTranslate,
        data: {
          'audio': audioBase64,
          'sourceLanguage': sourceLanguage,
          'targetLanguage': targetLanguage,
          if (previousInteractionId != null)
            'previousInteractionId': previousInteractionId,
          if (conversationId != null)
            'conversationId': conversationId,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final dataMap = responseData['data'] as Map<String, dynamic>?;
      AppLogger.d('API Response received - conversationId: ${dataMap?['conversationId']}');
      
      return ApiResponse.fromJson(
        responseData,
        (json) => VoiceTranslationResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.error?.toString() ?? 'Translation failed',
      );
    }
  }

  Future<ApiResponse<VoiceTranslationResponse>> handleFollowUp({
    required String interactionId,
    required String questionId,
  }) async {
    // Use mock data if backend is not configured
    if (!apiClient.isConfigured) {
      return _mockFollowUpResponse(questionId: questionId);
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.voiceFollowUp(interactionId),
        data: {
          'questionId': questionId,
        },
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => VoiceTranslationResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.error?.toString() ?? 'Follow-up failed',
      );
    }
  }

  ApiResponse<VoiceTranslationResponse> _mockVoiceTranslation({
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    return ApiResponse(
      success: true,
      data: VoiceTranslationResponse(
        interactionId: 'mock_interaction_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: 'mock_conversation_${DateTime.now().millisecondsSinceEpoch}',
        transcription: 'Hello, how are you?',
        translation: 'नमस्ते, आप कैसे हैं?',
        summary: 'Greeting exchange',
        followUpQuestions: [
          FollowUpQuestion(
            questionText: 'How can I help you today?',
            questionId: 'mock_question_1',
            category: 'general',
            priority: 1,
          ),
        ],
        detectedLanguage: sourceLanguage,
        urgency: 'routine',
      ),
    );
  }

  ApiResponse<VoiceTranslationResponse> _mockFollowUpResponse({
    required String questionId,
  }) {
    return ApiResponse(
      success: true,
      data: VoiceTranslationResponse(
        interactionId: 'mock_interaction_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: 'mock_conversation_${DateTime.now().millisecondsSinceEpoch}',
        transcription: '',
        translation: 'I can help you with translation services.',
        summary: 'Follow-up response',
        followUpQuestions: [],
        detectedLanguage: 'en',
        urgency: 'routine',
      ),
    );
  }
}
