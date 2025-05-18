import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit_example/main.dart';

// Import removed to fix unused import warning

void main() {
  group('RealTimeTranscriptionSection', () {
    testWidgets('displays initial state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RealTimeTranscriptionSection(
              isModelLoaded: false,
              isRecording: false,
              transcriptionText: '',
              segments: const [],
              onRecordPressed: () {},
            ),
          ),
        ),
      );

      // Verify initial UI elements
      expect(find.text('Real-time Transcription'), findsOneWidget);
      expect(find.text('No segments'), findsOneWidget);
      expect(find.text('Press the button to start recording'), findsOneWidget);

      // Button should be disabled when model is not loaded
      final buttonFinder = find.widgetWithText(
        ElevatedButton,
        'Start Recording',
      );
      expect(buttonFinder, findsOneWidget);
      expect(tester.widget<ElevatedButton>(buttonFinder).enabled, isFalse);
    });

    testWidgets('enables button when model is loaded', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RealTimeTranscriptionSection(
              isModelLoaded: true,
              isRecording: false,
              transcriptionText: '',
              segments: const [],
              onRecordPressed: () {},
            ),
          ),
        ),
      );

      // Button should be enabled when model is loaded
      final buttonFinder = find.widgetWithText(
        ElevatedButton,
        'Start Recording',
      );
      expect(buttonFinder, findsOneWidget);
      expect(tester.widget<ElevatedButton>(buttonFinder).enabled, isTrue);
    });

    testWidgets('shows recording state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RealTimeTranscriptionSection(
              isModelLoaded: true,
              isRecording: true,
              transcriptionText: 'Test recording',
              segments: const [],
              onRecordPressed: () {},
            ),
          ),
        ),
      );

      // Button should show stop recording text
      expect(find.text('Stop Recording'), findsOneWidget);
      expect(find.text('Test recording'), findsOneWidget);
    });

    testWidgets('displays transcription segments correctly', (
      WidgetTester tester,
    ) async {
      final segments = [
        TranscriptionSegment(
          id: 0,
          seek: 0,
          start: 0.0,
          end: 2.0,
          text: 'Hello',
          tokens: [1, 2, 3],
          temperature: 1.0,
          avgLogprob: -0.5,
          compressionRatio: 1.2,
          noSpeechProb: 0.1,
        ),
        TranscriptionSegment(
          id: 1,
          seek: 0,
          start: 2.0,
          end: 4.0,
          text: 'World',
          tokens: [4, 5, 6],
          temperature: 1.0,
          avgLogprob: -0.5,
          compressionRatio: 1.2,
          noSpeechProb: 0.1,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: RealTimeTranscriptionSection(
              isModelLoaded: true,
              isRecording: true,
              transcriptionText: 'Hello World',
              segments: segments,
              onRecordPressed: () {},
            ),
          ),
        ),
      );

      // Verify transcription text is displayed
      expect(find.text('Hello World'), findsOneWidget);

      // Verify segments are displayed
      expect(find.text('[0.00s - 2.00s]: Hello'), findsOneWidget);
      expect(find.text('[2.00s - 4.00s]: World'), findsOneWidget);
    });
  });
}
