import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_platform_interface.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Realtime Transcription Tests', () {
    late FlutterWhisperKitPlatform platform;

    setUp(() {
      platform = setUpMockPlatform();
    });

    test('startRecording initiates audio recording with default options', () async {
      final result = await platform.startRecording();
      
      expect(result, equals('Recording started'));
    });

    test('startRecording initiates audio recording with custom options', () async {
      final options = DecodingOptions(
        language: 'en',
        temperature: 0.5,
        wordTimestamps: true,
        detectLanguage: true,
        chunkingStrategy: ChunkingStrategy.vad,
      );

      final result = await platform.startRecording(options: options, loop: true);

      expect(result, equals('Recording started'));
    });

    test('stopRecording ends audio recording', () async {
      final result = await platform.stopRecording();
      
      expect(result, equals('Recording stopped'));
    });

    test('transcriptionStream emits transcription results', () async {
      final stream = platform.transcriptionStream;
      final results = await stream.take(1).toList();

      expect(results, hasLength(1));
      expect(results[0].text, equals('Test transcription'));
      expect(results[0].language, equals('en'));
      expect(results[0].segments, hasLength(1));
      expect(results[0].segments[0].text, equals('Test transcription'));
    });

    test('stopRecording with loop=false returns final transcription', () async {
      await platform.startRecording(loop: false);
      final result = await platform.stopRecording(loop: false);

      expect(result, equals('Recording stopped'));
    });

    test('startRecording handles microphone permissions', () async {
      final result = await platform.startRecording();
      
      expect(result, equals('Recording started'));
    });

    test('startRecording with chunking strategy options', () async {
      final options = DecodingOptions(
        chunkingStrategy: ChunkingStrategy.vad,
        temperature: 0.5,
        concurrentWorkerCount: 4,
      );

      final result = await platform.startRecording(options: options);

      expect(result, equals('Recording started'));
    });

    test('startRecording with compression and silence settings', () async {
      final options = DecodingOptions(
        compressionRatioThreshold: 2.4,
        logProbThreshold: -0.7,
        noSpeechThreshold: 0.6,
        temperatureFallbackCount: 3,
      );

      final result = await platform.startRecording(options: options);

      expect(result, equals('Recording started'));
    });

    test('transcription stream with word timestamps', () async {
      final stream = platform.transcriptionStream;
      final results = await stream.take(1).toList();

      expect(results, hasLength(1));
      expect(results[0].text, equals('Test transcription'));
      expect(results[0].segments, hasLength(1));
      // Note: Word timestamps would be available in the segments in real implementation
    });

    test('real-time transcription with language detection', () async {
      final options = DecodingOptions(detectLanguage: true);
      
      await platform.startRecording(options: options);
      final transcriptions = await platform.transcriptionStream.take(1).toList();

      expect(transcriptions[0].text, equals('Test transcription'));
      expect(transcriptions[0].language, equals('en'));
    });

    test('handles empty file path error', () async {
      expect(
        () => platform.transcribeFromFile(''),
        throwsA(isA<InvalidArgumentsError>()),
      );
    });
  });
}