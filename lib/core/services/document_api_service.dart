import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';
import '../../shared/models/document_translation_response.dart';

class DocumentApiService {
  final Dio _dio = apiClient.dio;

  Future<ApiResponse<DocumentTranslationResponse>> translateDocument({
    required String filePath,
    required String targetLanguage,
    required String mode, // 'translate' or 'summarize'
  }) async {
    // Use mock data if backend is not configured
    if (!apiClient.isConfigured) {
      return _mockDocumentTranslation(
        targetLanguage: targetLanguage,
        mode: mode,
      );
    }

    try {
      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        'targetLanguage': targetLanguage,
        'mode': mode,
      });

      final response = await _dio.post(
        ApiEndpoints.documentTranslate,
        data: formData,
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => DocumentTranslationResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.error?.toString() ?? 'Document translation failed',
      );
    }
  }

  ApiResponse<DocumentTranslationResponse> _mockDocumentTranslation({
    required String targetLanguage,
    required String mode,
  }) {
    final mockResult = mode == 'translate'
        ? 'This is a translated document. It contains important information about various topics.'
        : 'This document discusses key topics including technology, business, and innovation. The main points cover recent developments and future trends.';

    return ApiResponse(
      success: true,
      data: DocumentTranslationResponse(
        interactionId: 'mock_doc_${DateTime.now().millisecondsSinceEpoch}',
        result: mockResult,
        mode: mode,
        wordCount: mockResult.split(' ').length,
      ),
    );
  }
}

