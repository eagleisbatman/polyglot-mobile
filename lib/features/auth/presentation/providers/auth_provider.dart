import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

// Provider to access ClerkAuth from context
final clerkAuthProvider = Provider<ClerkAuth?>((ref) {
  // This will be set from widgets that have context
  // For now, return null - widgets will access ClerkAuth.of(context) directly
  return null;
});

// Provider to get auth state
final authStateProvider = StreamProvider<ClerkAuthState>((ref) {
  // This will be provided by ClerkAuthBuilder
  // For now, return empty stream
  return const Stream.empty();
});
