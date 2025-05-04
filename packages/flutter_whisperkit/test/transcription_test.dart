import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';
import 'package:flutter_whisperkit/src/whisper_kit_error.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('File Transcription', () {
    late FlutterWhisperKitPlatform platform;

    setUp(() {
      platform = setUpMockPlatform();
    });

    group('transcribeFromFile', () {
      test('returns JSON string for valid file path', () async {
        // Act
        final result = await platform.transcribeFromFile('test.wav');

        // Assert
        expect(result, isNotNull);
        expect(result, isA<TranscriptionResult>());

        // Parse the JSON string to verify content
        expect(result?.text, 'Hello world. This is a test.');
        expect(result?.segments.length, 2);
        expect(result?.language, 'en');
      });

      test('with custom DecodingOptions returns JSON string', () async {
        // Arrange
        final options = DecodingOptions(
          language: 'en',
          temperature: 0.7,
          wordTimestamps: true,
        );

        // Act
        final result = await platform.transcribeFromFile(
          'test.wav',
          options: options,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, isA<TranscriptionResult>());
      });

      test('throws InvalidArgumentsError with empty file path', () async {
        // Act & Assert
        expect(
          () => platform.transcribeFromFile(''),
          throwsA(isA<InvalidArgumentsError>()),
        );
      });
    });
  });
}
