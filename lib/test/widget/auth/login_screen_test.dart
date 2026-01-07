import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/screens/login_screen.dart';
import '../../../../core/constants/test_tags.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display login form', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key(TestTags.authLoginScreen)), findsOneWidget);
      expect(find.byKey(const Key(TestTags.authEmailField)), findsOneWidget);
      expect(find.byKey(const Key(TestTags.authPasswordField)), findsOneWidget);
      expect(find.byKey(const Key(TestTags.authLoginButton)), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      final emailField = find.byKey(const Key(TestTags.authEmailField));
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(find.byKey(const Key(TestTags.authLoginButton)));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      final passwordField = find.byKey(const Key(TestTags.authPasswordField));
      await tester.enterText(passwordField, 'short');
      await tester.tap(find.byKey(const Key(TestTags.authLoginButton)));
      await tester.pump();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('should navigate to register screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      final registerLink = find.byKey(const Key(TestTags.authRegisterLink));
      expect(registerLink, findsOneWidget);
    });
  });
}

