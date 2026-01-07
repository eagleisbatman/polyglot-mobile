import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';

class SupportedLanguage {
  final String code;
  final String name;
  final String nativeName;

  SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  factory SupportedLanguage.fromJson(Map<String, dynamic> json) {
    return SupportedLanguage(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
    );
  }
}

class LanguagesResponse {
  final List<SupportedLanguage> languages;
  final int count;

  LanguagesResponse({
    required this.languages,
    required this.count,
  });

  factory LanguagesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LanguagesResponse(
      languages: (data['languages'] as List<dynamic>)
          .map((item) =>
              SupportedLanguage.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: data['count'] as int,
    );
  }
}

class LanguagesApiService {
  final Dio _dio = apiClient.dio;

  Future<ApiResponse<LanguagesResponse>> getSupportedLanguages() async {
    try {
      final response = await _dio.get(ApiEndpoints.languages);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LanguagesResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch supported languages',
      );
    }
  }
}

