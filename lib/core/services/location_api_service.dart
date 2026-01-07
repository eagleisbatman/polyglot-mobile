import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/models/api_response.dart';

class LocationData {
  final String locationId;
  final String? detectedLanguage;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? heading;
  final double? speed;
  final String? country;
  final String? city;
  final DateTime? createdAt;

  LocationData({
    required this.locationId,
    this.detectedLanguage,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    this.country,
    this.city,
    this.createdAt,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LocationData(
      locationId: data['locationId'] as String,
      detectedLanguage: data['detectedLanguage'] as String?,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      accuracy: data['accuracy'] != null
          ? (data['accuracy'] as num).toDouble()
          : null,
      altitude: data['altitude'] != null
          ? (data['altitude'] as num).toDouble()
          : null,
      heading: data['heading'] != null
          ? (data['heading'] as num).toDouble()
          : null,
      speed:
          data['speed'] != null ? (data['speed'] as num).toDouble() : null,
      country: data['country'] as String?,
      city: data['city'] as String?,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : null,
    );
  }
}

class LocationApiService {
  final Dio _dio = apiClient.dio;

  Future<ApiResponse<LocationData>> saveLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    double? heading,
    double? speed,
    String? country,
    String? city,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.location,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          if (accuracy != null) 'accuracy': accuracy,
          if (altitude != null) 'altitude': altitude,
          if (heading != null) 'heading': heading,
          if (speed != null) 'speed': speed,
          if (country != null) 'country': country,
          if (city != null) 'city': city,
        },
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LocationData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to save location',
      );
    }
  }

  Future<ApiResponse<LocationData>> getSavedLocation() async {
    try {
      final response = await _dio.get(ApiEndpoints.location);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LocationData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ApiResponse(
          success: false,
          error: 'No location saved',
        );
      }
      return ApiResponse(
        success: false,
        error: e.response?.data['error'] as String? ??
            'Failed to retrieve location',
      );
    }
  }
}

