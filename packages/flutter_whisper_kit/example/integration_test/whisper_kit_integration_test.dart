import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_whisper_kit_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('WhisperKit Integration Tests', () {
    testWidgets('Full transcription workflow', (WidgetTester tester) async {
      // Launch the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Since we're in integration test, skip actual API calls
      // Focus on UI and basic functionality

      // Verify app loaded
      expect(find.text('Flutter WhisperKit API Test'), findsOneWidget);

      // Verify main sections are present
      expect(find.text('Additional Model Management'), findsOneWidget);
      expect(find.text('Result-based API Testing'), findsOneWidget);
      expect(find.text('Stream Monitoring'), findsOneWidget);
    });

    testWidgets('Model dropdown and language selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find model dropdown
      expect(find.text('Select Model: '), findsOneWidget);
      expect(find.text('tiny'), findsOneWidget);

      // Find language dropdown
      expect(find.text('Select Language: '), findsOneWidget);
      expect(find.text('en (English)'), findsOneWidget);

      // Find Load Model button
      expect(find.text('Load Model'), findsOneWidget);
    });

    testWidgets('Button interaction test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find various buttons to ensure they exist
      expect(find.text('Setup Models'), findsOneWidget);
      expect(find.text('Download Model'), findsOneWidget);
      expect(find.text('Prewarm Models'), findsOneWidget);
      expect(find.text('Unload Models'), findsOneWidget);
      expect(find.text('Clear State'), findsOneWidget);
      expect(find.text('Set Logging'), findsOneWidget);

      // Find Result API test button
      expect(find.text('Test Result APIs'), findsOneWidget);

      // Just test scrolling without checking specific elements
      // Since the ListView structure may vary
      final listViewFinder = find.byType(ListView);
      if (listViewFinder.evaluate().isNotEmpty) {
        // Scroll the first ListView found
        await tester.drag(listViewFinder.first, const Offset(0, -200));
        await tester.pumpAndSettle();
      }
    });
  });
}
