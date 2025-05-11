import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

    test('fromJson creates instance correctly', () {
      // Arrange
      final json = {
        'task': 'translate',
        'language': 'fr',
        'temperature': 0.5,
        'wordTimestamps': true,
      };

      // Act
      final options = DecodingOptions.fromJson(json);

      // Assert
      expect(options.task, DecodingTask.translate);
      expect(options.language, 'fr');
      expect(options.temperature, 0.5);
      expect(options.wordTimestamps, true);
    });
  });

  group('TranscriptionResult', () {
    test('fromJsonString creates instance correctly', () {
      // Arrange
      const jsonString = '''
      {
        "text": "Hello world. This is a test.",
        "segments": [
          {
            "id": 0,
            "seek": 0,
            "text": "Hello world.",
            "start": 0.0,
            "end": 2.0,
            "tokens": [1, 2, 3],
            "temperature": 1.0,
            "avgLogprob": -0.5,
            "compressionRatio": 1.2,
            "noSpeechProb": 0.1
          }
        ],
        "language": "en",
        "timings": {
          "fullPipeline": 1.0
        }
      }
      ''';

      // Act
      final result = TranscriptionResult.fromJsonString(jsonString);

      // Assert
      expect(result, isA<TranscriptionResult>());
      expect(result.text, 'Hello world. This is a test.');
      expect(result.segments.length, 1);
      expect(result.language, 'en');
      expect(result.timings, isA<TranscriptionTimings>());
    });

    test('toJson method returns correct map', () {
      // Arrange
      final result = TranscriptionResult(
        text: 'Test',
        segments: [
          TranscriptionSegment(
            id: 0,
            seek: 0,
            text: 'Test',
            start: 0.0,
            end: 1.0,
            tokens: [1, 2, 3],
          ),
        ],
        language: 'en',
        timings: const TranscriptionTimings(),
      );

      // Act
      final json = result.toJson();

      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['text'], 'Test');
      expect(json['segments'], isA<List>());
      expect(json['language'], 'en');
    });
  });

  group('Progress', () {
    test('creates instance with default values', () {
      // Act
      const progress = Progress();

      // Assert
      expect(progress.totalUnitCount, 0);
      expect(progress.completedUnitCount, 0);
      expect(progress.fractionCompleted, 0.0);
      expect(progress.isIndeterminate, false);
    });

    test('creates instance with custom values', () {
      // Act
      const progress = Progress(
        totalUnitCount: 100,
        completedUnitCount: 50,
        fractionCompleted: 0.5,
        isIndeterminate: false,
      );

      // Assert
      expect(progress.totalUnitCount, 100);
      expect(progress.completedUnitCount, 50);
      expect(progress.fractionCompleted, 0.5);
      expect(progress.isIndeterminate, false);
    });

    test('fromJson creates instance correctly', () {
      // Arrange
      final json = {
        'totalUnitCount': 100,
        'completedUnitCount': 75,
        'fractionCompleted': 0.75,
        'isIndeterminate': false,
      };

      // Act
      final progress = Progress.fromJson(json);

      // Assert
      expect(progress.totalUnitCount, 100);
      expect(progress.completedUnitCount, 75);
      expect(progress.fractionCompleted, 0.75);
      expect(progress.isIndeterminate, false);
    });

    test('toJson returns correct map', () {
      // Arrange
      const progress = Progress(
        totalUnitCount: 100,
        completedUnitCount: 25,
        fractionCompleted: 0.25,
      );

      // Act
      final json = progress.toJson();

      // Assert
      expect(json['totalUnitCount'], 100);
      expect(json['completedUnitCount'], 25);
      expect(json['fractionCompleted'], 0.25);
    });
  });
  
  group('fetchAvailableModels', () {
    setUp(() {
      setUpMockPlatform();
    });
    
    test('returns list of available models', () async {
      // Arrange
      final flutterWhisperKit = FlutterWhisperKit();
      
      // Act
      final models = await flutterWhisperKit.fetchAvailableModels();
      
      // Assert
      expect(models, isA<List<String>>());
      expect(models, isNotEmpty);
      expect(models, contains(matches(RegExp(r'(tiny|base|small|medium|large)'))));
    });
    
    test('accepts custom repository and matching patterns', () async {
      // Arrange
      final flutterWhisperKit = FlutterWhisperKit();
      
      // Act
      final models = await flutterWhisperKit.fetchAvailableModels(
        modelRepo: 'custom/repo',
        matching: ['tiny*', 'base*'],
      );
      
      // Assert
      expect(models, isA<List<String>>());
    });
  });
}
