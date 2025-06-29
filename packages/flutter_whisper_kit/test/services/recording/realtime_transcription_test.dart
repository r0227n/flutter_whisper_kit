import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

import '../../core/test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Realtime Transcription', () {
    late MockFlutterWhisperkitPlatform platform;

    setUp(() {
      platform = setUpMockPlatform();
    });

    test(
      'startRecording initiates audio recording with default options',
      () async {
        // Act & Assert
        expect(await platform.startRecording(), 'Recording started');
      },
    );

    test(
      'startRecording initiates audio recording with custom options',
      () async {
        // Arrange
        final options = DecodingOptions(
          language: 'en',
          temperature: 0.5,
          wordTimestamps: true,
        );

        // Act & Assert
        expect(
          await platform.startRecording(options: options),
          'Recording started',
        );
      },
    );

    test('stopRecording ends audio recording', () async {
      // Act & Assert
      expect(await platform.stopRecording(), 'Recording stopped');
    });

    test('transcriptionStream emits transcription results', () async {
      // Arrange
      const expectedResult = TranscriptionResult(
        text: 'Test transcription',
        language: 'en',
        segments: [],
        timings: TranscriptionTimings(
          pipelineStart: 0.0,
          firstTokenTime: 0.1,
          inputAudioSeconds: 1.0,
          audioLoading: 0.05,
          audioProcessing: 0.05,
          encoding: 0.1,
          decodingLoop: 0.3,
          fullPipeline: 0.5,
        ),
      );

      // Act
      final stream = platform.transcriptionStream;

      // Use a completer to properly handle the expectation
      final completer = Completer<void>();

      // Listen to the stream
      stream.listen((result) {
        if (result.text == 'Test transcription' && result.language == 'en') {
          completer.complete();
        }
      });

      // Emit test data after setting up the listener
      Future.microtask(() {
        platform.transcriptionController.add(expectedResult);
      });

      // Wait for the result
      await completer.future.timeout(const Duration(seconds: 5));
    });
  });
}
