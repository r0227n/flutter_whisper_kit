import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'test_utils/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('File Transcription', () {
    late FlutterWhisperKitPlatform plugin;

    setUp(() {
      // Create a mock method channel that provides test functionality
      final mockMethodChannel = MockMethodChannelFlutterWhisperkit();

      // Set the mock method channel as the platform instance
      FlutterWhisperKitPlatform.instance = mockMethodChannel;
      plugin = FlutterWhisperKitPlatform.instance;
    });

    group('transcribeFromFile', () {
      test('returns TranscriptionResult for valid file path', () async {
        // Act
        final result = await plugin.transcribeFromFile('test.wav');

        // Assert
        expect(result, isNotNull);
        expect(result, isA<TranscriptionResult>());
        expect(result!.text, 'Hello world. This is a test.');
        expect(result.segments.length, 2);
        expect(result.language, 'en');
      });

      test('with custom DecodingOptions returns TranscriptionResult', () async {
        // Arrange
        final options = DecodingOptions(
          language: 'en',
          temperature: 0.7,
          wordTimestamps: true,
        );

        // Act
        final result = await plugin.transcribeFromFile(
          'test.wav',
          options: options,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, isA<TranscriptionResult>());
      });

      test('parses word timestamps correctly when enabled', () async {
        // Arrange
        final options = DecodingOptions(language: 'en', wordTimestamps: true);

        // Act
        final result = await plugin.transcribeFromFile(
          'test_audio_with_words.wav',
          options: options,
        );

        // Assert
        expect(result, isNotNull);

        // Verify there are word timings in the result
        expect(result!.allWords, isNotEmpty);

        // Verify each word has start and end times
        for (final word in result.allWords) {
          expect(word.word, isNotEmpty);
          expect(word.start, isNotNull);
          expect(word.end, isNotNull);
          expect(word.end > word.start, isTrue);
        }
      });

      test('throws InvalidArgumentsError with empty file path', () async {
        // Act & Assert
        expect(
          () => plugin.transcribeFromFile(''),
          throwsA(isA<InvalidArgumentsError>()),
        );
      });
    });

    group('DecodingOptions', () {
      test('creates correct options object with default values', () {
        // Act
        final options = DecodingOptions();

        // Assert
        expect(options.verbose, false);
        expect(options.task, DecodingTask.transcribe);
        expect(options.temperature, 0.0);
      });

      test('creates correct options object with custom values', () {
        // Arrange & Act
        final options = DecodingOptions(
          task: DecodingTask.transcribe,
          language: 'en',
          temperature: 0.7,
          sampleLength: 100,
          temperatureFallbackCount: 5,
          usePrefillPrompt: true,
          usePrefillCache: true,
          detectLanguage: true,
          skipSpecialTokens: true,
          withoutTimestamps: false,
          maxInitialTimestamp: 1.0,
          wordTimestamps: true,
          clipTimestamps: [0.0],
          concurrentWorkerCount: 4,
          chunkingStrategy: ChunkingStrategy.vad,
        );

        // Assert
        expect(options, isA<DecodingOptions>());
        expect(options.task, DecodingTask.transcribe);
        expect(options.language, 'en');
        expect(options.temperature, 0.7);
        expect(options.sampleLength, 100);
        expect(options.temperatureFallbackCount, 5);
        expect(options.usePrefillPrompt, true);
        expect(options.usePrefillCache, true);
        expect(options.detectLanguage, true);
        expect(options.skipSpecialTokens, true);
        expect(options.withoutTimestamps, false);
        expect(options.maxInitialTimestamp, 1.0);
        expect(options.wordTimestamps, true);
        expect(options.chunkingStrategy, ChunkingStrategy.vad);
      });

      test('toJson method returns correct map', () {
        // Arrange
        final options = DecodingOptions(
          task: DecodingTask.transcribe,
          language: 'en',
          temperature: 0.7,
        );

        // Act
        final json = options.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['task'], 'transcribe');
        expect(json['language'], 'en');
        expect(json['temperature'], 0.7);
      });
    });
  });
}
