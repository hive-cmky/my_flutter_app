// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_app/main.dart';

void main() {
  testWidgets('Form screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the AppBar title is correct.
    expect(find.text('Resident Certificate'), findsOneWidget);

    // Verify that the main sections are present.
    expect(find.text('PERSONAL DETAILS'), findsOneWidget);
    expect(find.text('PRESENT ADDRESS'), findsOneWidget);
    expect(find.text('PERMANENT ADDRESS'), findsOneWidget);
    expect(find.text('GUARDIAN DETAILS'), findsOneWidget);
    expect(find.text('PURPOSE'), findsOneWidget);
    expect(find.text('SUPPORTING DOCUMENT'), findsOneWidget);
    expect(find.text('DECLARATION'), findsOneWidget);

    // Verify that the submit button is present.
    expect(find.widgetWithText(ElevatedButton, 'Submit'), findsOneWidget);

    // Example: Find the 'Name' field
    expect(find.text('Name *'), findsOneWidget);
  });
}
