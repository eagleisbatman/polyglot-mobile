import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'localization/l10n/app_localizations.dart';

// Set to true to bypass Clerk authentication in debug mode
// Set to false to enable proper Clerk authentication
// TEMPORARY: Bypassing auth to test app functionality while debugging Clerk
const bool kBypassAuth = true;

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bypass authentication in debug mode for development
    if (kBypassAuth) {
      return _buildMainApp(ref);
    }

    return ClerkAuthBuilder(
      signedInBuilder: (context, authState) {
        debugPrint('ClerkAuthBuilder: User is SIGNED IN');
        return _buildMainApp(ref);
      },
      signedOutBuilder: (context, authState) {
        debugPrint('ClerkAuthBuilder: User is SIGNED OUT');
        // User is signed out - show login
        return MaterialApp(
          title: 'Polyglot',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const ClerkErrorListener(
            child: LoginScreen(),
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }

  Widget _buildMainApp(WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Polyglot',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
