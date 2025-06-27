// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/main.dart';
import 'package:todo_app/providers/todo_provider.dart';

void main() {
  testWidgets('Day Care app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(todoProvider: TodoProvider()));

    // Verify that our app title is displayed.
    expect(find.text('Day Care'), findsOneWidget);
    
    // Verify that the clock icon is present
    expect(find.byIcon(Icons.access_time), findsOneWidget);
    
    // Verify that the add button is present
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
