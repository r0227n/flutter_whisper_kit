import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit_example/main.dart';

// Import removed to fix unused import warning

void main() {
  group('FileTranscriptionSection', () {
    testWidgets('displays initial state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: FileTranscriptionSection(
              isModelLoaded: false,
              isTranscribingFile: false,
              fileTranscriptionText: '',
              fileTranscriptionResult: null,
              onTranscribePressed: () {},
            ),
          ),
        ),
      );

      // Verify initial UI elements
      expect(find.text('File Transcription'), findsOneWidget);
      expect(
        find.text('Press the button to transcribe a file'),
        findsOneWidget,
      );

      // Button should be disabled when model is not loaded
      final buttonFinder = find.widgetWithText(
        ElevatedButton,
        'Transcribe from File',
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
            child: FileTranscriptionSection(
              isModelLoaded: true,
              isTranscribingFile: false,
              fileTranscriptionText: '',
              fileTranscriptionResult: null,
              onTranscribePressed: () {},
            ),
          ),
        ),
      );

      // Button should be enabled when model is loaded
      final buttonFinder = find.widgetWithText(
        ElevatedButton,
        'Transcribe from File',
      );
      expect(buttonFinder, findsOneWidget);
      expect(tester.widget<ElevatedButton>(buttonFinder).enabled, isTrue);
    });

    testWidgets('shows loading state during transcription', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: FileTranscriptionSection(
              isModelLoaded: true,
              isTranscribingFile: true,
              fileTranscriptionText: 'Transcribing file...',
              fileTranscriptionResult: null,
              onTranscribePressed: () {},
            ),
          ),
        ),
      );

      // Button should show loading text
      expect(find.text('Transcribing...'), findsOneWidget);
      expect(find.text('Transcribing file...'), findsOneWidget);
    });

    testWidgets('displays transcription results correctly', (
      WidgetTester tester,
    ) async {
      final mockResult = TranscriptionResult(
        text: 'Hello world',
        segments: [
          TranscriptionSegment(
            id: 0,
            seek: 0,
            start: 0.0,
            end: 2.0,
            text: 'Hello world',
            tokens: [1, 2, 3],
            temperature: 1.0,
            avgLogprob: -0.5,
            compressionRatio: 1.2,
            noSpeechProb: 0.1,
          ),
        ],
        language: 'en',
        timings: const TranscriptionTimings(
          fullPipeline: 1.5,
          inputAudioSeconds: 0.75, // This will give a realTimeFactor of 2.0
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: FileTranscriptionSection(
              isModelLoaded: true,
              isTranscribingFile: false,
              fileTranscriptionText: 'Hello world',
              fileTranscriptionResult: mockResult,
              onTranscribePressed: () {},
            ),
          ),
        ),
      );

      // Verify transcription text is displayed
      expect(find.text('Hello world'), findsOneWidget);

      // Verify language detection is displayed
      expect(find.text('Detected Language:'), findsOneWidget);
      expect(find.text('en'), findsOneWidget);

      // Verify segments are displayed
      expect(find.text('Segments:'), findsOneWidget);
      expect(find.text('[0.00s - 2.00s]: Hello world'), findsOneWidget);

      // Verify performance metrics are displayed
      expect(find.text('Performance:'), findsOneWidget);
      expect(find.text('Real-time factor: 2.00x'), findsOneWidget);
      expect(find.text('Processing time: 1.50s'), findsOneWidget);
    });
  });
}
