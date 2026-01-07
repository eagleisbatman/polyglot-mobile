import 'package:dio/dio.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import '../api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final BuildContext? _context;

  AuthInterceptor(this._context);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    // Get token from Clerk - TODO: Fix Clerk API integration
    // Temporarily disabled to allow app to compile
    // if (_context != null) {
    //   try {
    //     final auth = ClerkAuth.of(_context!);
    //     if (auth.isSignedIn) {
    //       final session = auth.session;
    //       if (session != null) {
    //         // TODO: Implement proper token retrieval
    //       }
    //     }
    //   } catch (e) {
    //     // Token fetch failed, continue without auth header
    //   }
    // }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Clerk handles token refresh automatically
    // Just pass through errors
    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    final publicPaths = [
      ApiEndpoints.health,
      ApiEndpoints.languages,
    ];
    return publicPaths.contains(path);
  }
}
