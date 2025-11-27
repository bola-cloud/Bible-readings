// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
    testWidgets('Home page smoke test', (WidgetTester tester) async {
    // Wrap Home in MaterialApp to provide Material widgets + Directionality
    await tester.pumpWidget(const MaterialApp(home: Home()));

    // Verify that the app bar title is present
    expect(find.text('My Coffee Id'), findsOneWidget);
    // Verify that a body text from Home appears
    expect(find.textContaining('How I like my coffee'), findsOneWidget);
    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
