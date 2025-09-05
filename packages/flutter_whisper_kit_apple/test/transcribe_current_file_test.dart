import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_platform_interface.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('File Transcription Tests', () {
    late FlutterWhisperKitPlatform platform;

    setUp(() {
      platform = setUpMockPlatform();
    });

    tearDown(() {
      (platform as MockFlutterWhisperkitPlatform).transcriptionController
          .close();
      (platform as MockFlutterWhisperkitPlatform).progressController.close();
    });

    group('transcribeFromFile', () {
      test('returns TranscriptionResult for valid file path', () async {
        final result = await platform.transcribeFromFile('test.wav');

        expect(result?.text, 'Hello world. This is a test.');
        expect(result?.segments.length, 2);
        expect(result?.language, 'en');
        expect(result?.segments[0].text, 'Hello world.');
        expect(result?.segments[0].start, 0.0);
        expect(result?.segments[0].end, 2.0);
        expect(result?.segments[1].text, 'This is a test.');
      });

      test('with custom DecodingOptions returns TranscriptionResult', () async {
        final options = DecodingOptions(
          language: 'en',
          temperature: 0.7,
          wordTimestamps: true,
          compressionRatioThreshold: 2.2,
          logProbThreshold: -0.8,
          noSpeechThreshold: 0.6,
        );

        final result = await platform.transcribeFromFile(
          'test.wav',
          options: options,
        );

        expect(result?.text, 'Hello world. This is a test.');
        expect(result?.language, 'en');
      });

      test('parses word timestamps correctly when enabled', () async {
        final options = DecodingOptions(language: 'en', wordTimestamps: true);

        final result = await platform.transcribeFromFile(
          'test_audio_with_words.wav',
          options: options,
        );

        expect(result?.text, 'Hello world. This is a test.');
        expect(result?.segments, hasLength(2));

        // Check word timestamps in segments
        final segment1 = result!.segments[0];
        expect(segment1.words, hasLength(2));
        expect(segment1.words![0].word, 'Hello');
        expect(segment1.words![0].start, 0.0);
        expect(segment1.words![0].end, 1.0);
        expect(segment1.words![0].probability, 0.9);
        expect(segment1.words![1].word, 'world');
        expect(segment1.words![1].start, 1.0);
        expect(segment1.words![1].end, 2.0);
        expect(segment1.words![1].probability, 0.8);
      });

      test('throws InvalidArgumentsError with empty file path', () async {
        expect(
          () => platform.transcribeFromFile(''),
          throwsA(isA<InvalidArgumentsError>()),
        );
      });

      test('transcribes with different languages', () async {
        final testCases = [
          {'language': 'es', 'filename': 'spanish.wav'},
          {'language': 'fr', 'filename': 'french.wav'},
          {'language': 'de', 'filename': 'german.wav'},
          {'language': 'ja', 'filename': 'japanese.wav'},
        ];

        for (final testCase in testCases) {
          final result = await platform.transcribeFromFile(
            testCase['filename'] as String,
            options: DecodingOptions(language: testCase['language'] as String),
          );

          expect(result?.text, isNotEmpty);
          expect(result?.language, 'en'); // Mock always returns 'en'
        }
      });

      test('transcribes with temperature fallback', () async {
        final options = DecodingOptions(
          temperature: 0.0,
          temperatureFallbackCount: 5,
          temperatureIncrementOnFallback: 0.2,
        );

        final result = await platform.transcribeFromFile(
          'audio.wav',
          options: options,
        );

        expect(result?.text, 'Hello world. This is a test.');
      });

      test('transcribes with prefix prompt', () async {
        final options = DecodingOptions(
          promptTokens: [1, 2, 3], // Token IDs as integers
          usePrefillPrompt: true,
        );

        final result = await platform.transcribeFromFile(
          'medical_audio.wav',
          options: options,
        );

        expect(result?.text, 'Hello world. This is a test.');
      });
    });

    group('DecodingOptions', () {
      test('creates correct options object with default values', () {
        final options = DecodingOptions();

        expect(options.verbose, false);
        expect(options.task, DecodingTask.transcribe);
        expect(options.temperature, 0.0);
        expect(options.detectLanguage, false);
        expect(options.wordTimestamps, false);
        expect(options.withoutTimestamps, false);
        expect(
          options.chunkingStrategy,
          ChunkingStrategy.vad,
        ); // Default is vad
      });

      test('creates correct options object with custom values', () {
        final options = DecodingOptions(
          task: DecodingTask.transcribe,
          language: 'en',
          temperature: 0.7,
          sampleLength: 100,
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
          compressionRatioThreshold: 2.4,
          logProbThreshold: -1.0,
          noSpeechThreshold: 0.6,
          temperatureFallbackCount: 3,
          promptTokens: [1, 2], // Token IDs as integers
        );

        expect(options, isA<DecodingOptions>());
        expect(options.task, DecodingTask.transcribe);
        expect(options.language, 'en');
        expect(options.temperature, 0.7);
        expect(options.sampleLength, 100);
        expect(options.usePrefillPrompt, true);
        expect(options.usePrefillCache, true);
        expect(options.detectLanguage, true);
        expect(options.skipSpecialTokens, true);
        expect(options.withoutTimestamps, false);
        expect(options.maxInitialTimestamp, 1.0);
        expect(options.wordTimestamps, true);
        expect(options.chunkingStrategy, ChunkingStrategy.vad);
        expect(options.compressionRatioThreshold, 2.4);
        expect(options.logProbThreshold, -1.0);
        expect(options.noSpeechThreshold, 0.6);
        expect(options.temperatureFallbackCount, 3);
        expect(options.promptTokens, equals([1, 2]));
      });

      test('toJson method returns correct map', () {
        final options = DecodingOptions(
          task: DecodingTask.transcribe,
          language: 'en',
          temperature: 0.7,
          wordTimestamps: true,
          detectLanguage: false,
          chunkingStrategy: ChunkingStrategy.none,
        );

        final json = options.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['task'], 'transcribe');
        expect(json['language'], 'en');
        expect(json['temperature'], 0.7);
        expect(json['wordTimestamps'], true);
        expect(json['detectLanguage'], false);
        expect(json['chunkingStrategy'], 'none');
      });

      test('creates options with various temperature values', () {
        expect(
          () => DecodingOptions(temperature: -0.1),
          returnsNormally,
        ); // No validation in current implementation
        expect(() => DecodingOptions(temperature: 1.1), returnsNormally);
        expect(() => DecodingOptions(temperature: 0.0), returnsNormally);
        expect(() => DecodingOptions(temperature: 1.0), returnsNormally);
        expect(() => DecodingOptions(temperature: 0.5), returnsNormally);
      });

      test('validates temperature fallback settings', () {
        expect(
          () => DecodingOptions(temperatureFallbackCount: -1),
          returnsNormally,
        ); // No validation in current implementation
        expect(
          () => DecodingOptions(temperatureIncrementOnFallback: 0.1),
          returnsNormally,
        );
        expect(
          () => DecodingOptions(temperatureIncrementOnFallback: 0.5),
          returnsNormally,
        );
      });

      test('creates options with various worker counts', () {
        expect(
          () => DecodingOptions(concurrentWorkerCount: 0),
          returnsNormally,
        ); // No validation in current implementation
        expect(
          () => DecodingOptions(concurrentWorkerCount: -1),
          returnsNormally,
        );
        expect(
          () => DecodingOptions(concurrentWorkerCount: 1),
          returnsNormally,
        );
        expect(
          () => DecodingOptions(concurrentWorkerCount: 8),
          returnsNormally,
        );
      });

      test('validates compression ratio threshold', () {
        expect(
          () => DecodingOptions(compressionRatioThreshold: 0.9),
          returnsNormally,
        );
        expect(
          () => DecodingOptions(compressionRatioThreshold: 1.0),
          returnsNormally,
        );
        expect(
          () => DecodingOptions(compressionRatioThreshold: 2.4),
          returnsNormally,
        );
      });

      test('creates options with various timestamp configurations', () {
        expect(
          () => DecodingOptions(withoutTimestamps: true, wordTimestamps: true),
          returnsNormally, // No validation in current implementation
        );
        expect(
          () => DecodingOptions(withoutTimestamps: false, wordTimestamps: true),
          returnsNormally,
        );
        expect(
          () => DecodingOptions(withoutTimestamps: true, wordTimestamps: false),
          returnsNormally,
        );
      });
    });
  });
}
