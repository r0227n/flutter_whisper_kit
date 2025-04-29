import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'test_utils/mocks.dart';
import 'test_utils/mock_whisper_kit_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('File Transcription', () {
    late FlutterWhisperkitApple plugin;
    
    group('Platform Interface', () {
      test('FlutterWhisperkitApple extends FlutterWhisperkitPlatform', () {
        // Assert
        expect(
          plugin,
          isA<FlutterWhisperkitPlatform>(),
        );
      });
    });

    setUp(() {
      // Create a method channel with mock WhisperKitMessage
      final mockWhisperKitMessage = MockWhisperKitMessage();
      final methodChannel = MethodChannelFlutterWhisperkitApple(
        whisperKitMessage: mockWhisperKitMessage
      );
      
      // Create plugin instance with mock method channel
      plugin = FlutterWhisperkitApple(methodChannel: methodChannel);
      
      // Set up mock platform interface
      setUpMockPlatform();
    });

    group('transcribeFromFile', () {
      test('returns JSON string for valid file path', () async {
        // Act
        final jsonString = await plugin.transcribeFromFile('test.wav');
        
        // Assert
        expect(jsonString, isNotNull);
        expect(jsonString, isA<String>());
        
        // Parse the JSON string to verify content
        final result = TranscriptionResult.fromJsonString(jsonString!);
        expect(result.text, 'Hello world. This is a test.');
        expect(result.segments.length, 2);
        expect(result.language, 'en');
      });

      test('with custom DecodingOptions returns JSON string', () async {
        // Arrange
        final options = DecodingOptions(
          language: 'en',
          temperature: 0.7,
          wordTimestamps: true,
        );

        // Act
        final jsonString = await plugin.transcribeFromFile(
          'test.wav',
          options: options,
        );
        
        // Assert
        expect(jsonString, isNotNull);
        expect(jsonString, isA<String>());
        
        // Verify we can parse the JSON
        final result = TranscriptionResult.fromJsonString(jsonString!);
        expect(result, isA<TranscriptionResult>());
      });

      test('throws WhisperKitError with empty file path', () async {
        // Act & Assert
        expect(
          () => plugin.transcribeFromFile(''),
          throwsA(isA<WhisperKitError>()),
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
