import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

import 'test_utils/mocks.dart';

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
      // Act
      final stream = platform.transcriptionStream;

      // Assert
      expect(
        stream,
        emitsThrough(
          predicate<TranscriptionResult>(
            (result) =>
                result.text == 'Test transcription' && result.language == 'en',
          ),
        ),
      );
    });
  });
}
