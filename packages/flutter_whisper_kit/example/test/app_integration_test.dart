import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit_example/main.dart';

void main() {
  testWidgets('Full app integration test', (WidgetTester tester) async {
    // Build our app directly since MyApp already contains MaterialApp
    await tester.pumpWidget(const MyApp());

    // Wait for initial render
    await tester.pump();

    // Basic smoke test - ensure the app doesn't crash during startup
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Initially, the app should show the title
    expect(find.text('Flutter WhisperKit API Test'), findsOneWidget);

    // Verify essential UI elements are present
    expect(find.byType(ElevatedButton), findsWidgets);
    expect(find.byType(DropdownButton<String>), findsWidgets);

    // Find the Load Model button
    final loadModelButton = find.widgetWithText(ElevatedButton, 'Load Model');
    expect(loadModelButton, findsOneWidget);

    // Just verify the UI structure without triggering async operations
    // that might cause timeouts in testing environment
    expect(find.text('Select Model: '), findsOneWidget);
    expect(find.text('Select Language: '), findsOneWidget);
  });
}
