import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/user/presentation/screens/user_profile_screen.dart';
import '../../../../core/constants/test_tags.dart';

void main() {
  group('UserProfileScreen Widget Tests', () {
    testWidgets('should display profile screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: UserProfileScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key(TestTags.userProfileScreen)), findsOneWidget);
    });

    testWidgets('should display edit button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: UserProfileScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key(TestTags.userProfileEditButton)), findsOneWidget);
    });

    testWidgets('should show edit mode when edit button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: UserProfileScreen(),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key(TestTags.userProfileEditButton)));
      await tester.pump();

      expect(find.byKey(const Key(TestTags.userProfileSaveButton)), findsOneWidget);
      expect(find.byKey(const Key(TestTags.userProfileCancelButton)), findsOneWidget);
    });
  });
}

