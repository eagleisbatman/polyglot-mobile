import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
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

  // Get Clerk publishable key
  final publishableKey = dotenv.env['CLERK_PUBLISHABLE_KEY'];
  if (publishableKey == null || publishableKey.isEmpty) {
    throw Exception('CLERK_PUBLISHABLE_KEY is required in .env file');
  }

  runApp(
    ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: publishableKey,
      ),
      child: const ProviderScope(
        child: App(),
      ),
    ),
  );
}

