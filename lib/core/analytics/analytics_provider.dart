import 'analytics_service.dart';

/// Provider for AnalyticsService (Riverpod)
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final service = AnalyticsService();
  // Initialize with console provider for debugging
  service.initialize(providers: [ConsoleAnalyticsProvider()]);
  return service;
});

