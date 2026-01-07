import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/storage_service.dart';
import 'core/analytics/analytics_service.dart';
import 'core/analytics/analytics_events.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize storage service
  await StorageService.init();

  // Initialize analytics
  AnalyticsService().initialize();
  AnalyticsService().trackEvent(AnalyticsEvents.appLaunched);

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
