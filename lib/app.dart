import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'localization/l10n/app_localizations.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Initialize device authentication on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
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
      builder: (context, child) {
        // Show splash/loading while authenticating
        if (authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading) {
          return const SplashScreen();
        }

        // Show error if authentication failed
        if (authState.status == AuthStatus.error) {
          return AuthErrorScreen(
            error: authState.error ?? 'Unknown error',
            onRetry: () => ref.read(authProvider.notifier).initialize(),
          );
        }

        // Show onboarding for new users
        if (authState.status == AuthStatus.onboarding) {
          return const OnboardingScreen();
        }

        // Show main app (authenticated)
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// Splash screen shown during device registration
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6366F1), // Indigo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.translate_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Polyglot',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Real-time Translation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen shown when authentication fails
class AuthErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AuthErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Connection Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to connect to our servers.\nPlease check your internet connection.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
