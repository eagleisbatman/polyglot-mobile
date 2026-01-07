import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';

class UserStats {
  final int totalTranslations;
  final Map<String, int> translationsByType;
  final Map<String, int> translationsByLanguage;
  final Map<String, int> recentActivity;

  UserStats({
    required this.totalTranslations,
    required this.translationsByType,
    required this.translationsByLanguage,
    required this.recentActivity,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return UserStats(
      totalTranslations: data['totalTranslations'] as int,
      translationsByType: Map<String, int>.from(
        data['translationsByType'] as Map,
      ),
      translationsByLanguage: Map<String, int>.from(
        data['translationsByLanguage'] as Map,
      ),
      recentActivity: Map<String, int>.from(
        data['recentActivity'] as Map,
      ),
    );
  }
}

class UsageStats {
  final Map<String, dynamic> period;
  final int totalUsage;
  final Map<String, int> dailyUsage;
  final Map<int, int> hourlyUsage;
  final double averagePerDay;

  UsageStats({
    required this.period,
    required this.totalUsage,
    required this.dailyUsage,
    required this.hourlyUsage,
    required this.averagePerDay,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return UsageStats(
      period: Map<String, dynamic>.from(data['period'] as Map),
      totalUsage: data['totalUsage'] as int,
      dailyUsage: Map<String, int>.from(
        (data['dailyUsage'] as Map).map(
          (key, value) => MapEntry(key.toString(), value as int),
        ),
      ),
      hourlyUsage: Map<int, int>.from(
        (data['hourlyUsage'] as Map).map(
          (key, value) => MapEntry(int.parse(key.toString()), value as int),
        ),
      ),
      averagePerDay: (data['averagePerDay'] as num).toDouble(),
    );
  }
}

class StatsApiService {
  final Dio _dio = apiClient.dio;

  Future<ApiResponse<UserStats>> getStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.stats);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserStats.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch statistics',
      );
    }
  }

  Future<ApiResponse<UsageStats>> getUsageStats({int days = 30}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.statsUsage,
        queryParameters: {'days': days},
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UsageStats.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to fetch usage statistics',
      );
    }
  }
}

