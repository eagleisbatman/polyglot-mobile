import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/chat/presentation/screens/unified_chat_screen.dart';
import '../../features/user/presentation/screens/user_profile_screen.dart';
import '../../features/preferences/presentation/screens/preferences_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
