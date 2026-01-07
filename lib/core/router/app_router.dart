import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import '../../features/chat/presentation/screens/unified_chat_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/user/presentation/screens/user_profile_screen.dart';
import '../../features/preferences/presentation/screens/preferences_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';

// Match the bypass flag from app.dart
const bool _kBypassAuth = kDebugMode;

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Bypass auth in debug mode
      if (_kBypassAuth) {
        return null; // Allow all routes
      }

      final route = state.uri.toString();
      
      // Try to get Clerk auth state
      try {
        final auth = ClerkAuth.of(context);
        final isAuthenticated = auth.isSignedIn;

        // Public routes
        if (route == '/login' || route == '/register') {
          // If already authenticated, redirect to main screen
          if (isAuthenticated) {
            return '/';
          }
          return null; // Allow access
        }

        // Protected routes - require authentication
        if (!isAuthenticated) {
          return '/login';
        }

        return null; // Allow access
      } catch (e) {
        // Clerk not initialized yet, allow access to login/register
        if (route == '/login' || route == '/register') {
          return null;
        }
        return '/login';
      }
    },
    refreshListenable: authNotifier,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Main unified chat screen
      GoRoute(
        path: '/',
        name: 'chat',
        builder: (context, state) => const UnifiedChatScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/preferences',
        name: 'preferences',
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
  );
});

// Listenable for GoRouter to react to auth state changes
class _AuthNotifier extends ChangeNotifier {
  final Ref _ref;
  _AuthNotifier(this._ref) {
    // Listen to Clerk auth state changes
    // Note: This is a simplified approach - in production you'd want to listen to Clerk's auth state stream
    // For now, ClerkAuthBuilder handles the main auth state changes
  }
}
