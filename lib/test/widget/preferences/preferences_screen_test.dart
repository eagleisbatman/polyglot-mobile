import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/preferences/presentation/screens/preferences_screen.dart';
import '../../../../core/constants/test_tags.dart';

void main() {
  group('PreferencesScreen Widget Tests', () {
    testWidgets('should display preferences screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PreferencesScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key(TestTags.preferencesScreen)), findsOneWidget);
    });

    testWidgets('should display notification switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PreferencesScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key(TestTags.preferencesNotificationsSwitch)), findsOneWidget);
    });

    testWidgets('should display location switch', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PreferencesScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key(TestTags.preferencesLocationSwitch)), findsOneWidget);
    });
  });
}

