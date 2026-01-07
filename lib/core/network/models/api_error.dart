import 'package:dio/dio.dart';

enum ApiErrorType {
  networkError,
  timeoutError,
  serverError,
  unauthorizedError,
  forbiddenError,
  notFoundError,
  rateLimitError,
  validationError,
  unknownError,
}

class ApiError {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiError.fromDioException(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiError(
            type: ApiErrorType.timeoutError,
            message: 'Connection timeout. Please check your internet.',
          );
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 401) {
            return ApiError(
              type: ApiErrorType.unauthorizedError,
              message: 'Unauthorized. Please login again.',
              statusCode: statusCode,
            );
          } else if (statusCode == 403) {
            return ApiError(
              type: ApiErrorType.forbiddenError,
              message: 'Access forbidden.',
              statusCode: statusCode,
            );
          } else if (statusCode == 404) {
            return ApiError(
              type: ApiErrorType.notFoundError,
              message: 'Resource not found.',
              statusCode: statusCode,
            );
          } else if (statusCode == 400) {
            return ApiError(
              type: ApiErrorType.validationError,
              message: 'Validation error. Please check your input.',
              statusCode: statusCode,
              details: e.response?.data as Map<String, dynamic>?,
            );
          } else if (statusCode == 429) {
            return ApiError(
              type: ApiErrorType.rateLimitError,
              message: 'Too many requests. Please try again later.',
              statusCode: statusCode,
            );
          } else if (statusCode != null && statusCode >= 500) {
            return ApiError(
              type: ApiErrorType.serverError,
              message: 'Server error. Please try again later.',
              statusCode: statusCode,
            );
          }
          break;
        case DioExceptionType.cancel:
          return ApiError(
            type: ApiErrorType.unknownError,
            message: 'Request cancelled.',
          );
        case DioExceptionType.unknown:
          return ApiError(
            type: ApiErrorType.networkError,
            message: 'No internet connection.',
          );
        default:
          break;
      }
    }
    return ApiError(
      type: ApiErrorType.unknownError,
      message: 'Unknown error occurred.',
    );
  }

  @override
  String toString() => message;
}

