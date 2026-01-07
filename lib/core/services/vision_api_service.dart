import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';
import '../../shared/models/vision_translation_response.dart';

class VisionApiService {
  final Dio _dio = apiClient.dio;

  Future<ApiResponse<VisionTranslationResponse>> translateImage({
    required String imagePath,
    required String targetLanguage,
  }) async {
    // Use mock data if backend is not configured
    if (!apiClient.isConfigured) {
      return _mockVisionTranslation(targetLanguage: targetLanguage);
    }

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
        'targetLanguage': targetLanguage,
      });

      final response = await _dio.post(
        ApiEndpoints.visionTranslate,
        data: formData,
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => VisionTranslationResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.error?.toString() ?? 'Image translation failed',
      );
    }
  }

  ApiResponse<VisionTranslationResponse> _mockVisionTranslation({
    required String targetLanguage,
  }) {
    return ApiResponse(
      success: true,
      data: VisionTranslationResponse(
        interactionId: 'mock_vision_${DateTime.now().millisecondsSinceEpoch}',
        translatedText: 'Welcome to our restaurant. Today\'s special is pasta.',
        confidence: 'high',
        detectedLanguage: 'en',
      ),
    );
  }
}

