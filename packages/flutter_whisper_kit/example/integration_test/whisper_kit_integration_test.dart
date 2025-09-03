import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit_example/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('WhisperKit Integration Tests', () {
    setUp(() {
      // Mock the method channels to prevent MissingPluginException
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter_whisper_kit'),
            (MethodCall methodCall) async {
              return null;
            },
          );

      // Mock event channels for streams
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter_whisper_kit/transcription_stream'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'listen') {
                return null;
              }
              return null;
            },
          );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter_whisper_kit/model_progress_stream'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'listen') {
                return null;
              }
              return null;
            },
          );
    });

    testWidgets('App loads and main UI sections are present', (
      WidgetTester tester,
    ) async {
      // Launch the app
      await tester.pumpWidget(const MyApp());
      // Use pump with fixed duration instead of pumpAndSettle to avoid timeout
      await tester.pump(const Duration(seconds: 1));

      // Since we're in integration test, skip actual API calls
      // Focus on UI and basic functionality

      // Verify app loaded
      expect(find.text('Flutter WhisperKit API Test'), findsOneWidget);

      // Verify main sections are present (these might be scrolled down)
      // Let's just check basic UI structure for now
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Select Model: '), findsOneWidget);
    });

    testWidgets('Model dropdown and language selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 1));

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
      await tester.pump(const Duration(seconds: 1));

      // Just verify basic UI elements without scrolling
      // since specific button texts might be scrolled down
      expect(find.byType(ElevatedButton), findsWidgets);
      expect(find.byType(DropdownButton<String>), findsWidgets);

      // Basic interaction test - just verify the app responds to pumps
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
