// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils/mocks.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(buildTestApp());

    // Verify that app title is displayed
    expect(find.text('Flutter WhisperKit Example'), findsOneWidget);

    // Verify that buttons are present instead of looking for dropdowns
    expect(find.byType(ElevatedButton), findsWidgets);

    // Verify that file transcription section is present
    expect(find.text('File Transcription'), findsOneWidget);

    // Verify that real-time transcription section is present
    expect(find.text('Real-time Transcription'), findsOneWidget);
  });
}
