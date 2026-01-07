import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

extension WidgetTesterExtensions on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    await pumpWidget(
      MaterialApp(
        home: widget,
      ),
    );
  }
}

