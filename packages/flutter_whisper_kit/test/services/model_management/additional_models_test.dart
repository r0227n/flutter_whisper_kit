import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

void main() {
  group('DeviceSupport', () {
    test('creates instance with required parameters', () {
      // Arrange & Act
      final deviceSupport = DeviceSupport(
        chips: 'A12, A13',
        identifiers: ['iPhone12,1', 'iPhone12,3'],
        models: ModelSupport(
          defaultModel: 'tiny',
          supported: ['tiny', 'base'],
          disabled: [],
        ),
      );

      // Assert
      expect(deviceSupport.chips, 'A12, A13');
      expect(deviceSupport.identifiers, ['iPhone12,1', 'iPhone12,3']);
      expect(deviceSupport.models, isA<ModelSupport>());
    });

    test('toJson returns correct map', () {
      // Arrange
      final deviceSupport = DeviceSupport(
        chips: 'A14',
        identifiers: ['iPhone13,1'],
        models: ModelSupport(
          defaultModel: 'base',
          supported: ['base', 'small'],
          disabled: ['large'],
        ),
      );

      // Act
      final json = deviceSupport.toJson();

      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['chips'], 'A14');
      expect(json['identifiers'], ['iPhone13,1']);
      expect(json['models'], isA<Map<String, dynamic>>());
    });

    test('fromJson creates instance correctly', () {
      // Arrange
      final json = {
        'chips': 'A15',
        'identifiers': ['iPhone14,1', 'iPhone14,2'],
        'models': {
          'default': 'small',
          'supported': ['tiny', 'base', 'small'],
          'disabled': ['medium', 'large'],
        },
      };

      // Act
      final deviceSupport = DeviceSupport.fromJson(json);

      // Assert
      expect(deviceSupport.chips, 'A15');
      expect(deviceSupport.identifiers, ['iPhone14,1', 'iPhone14,2']);
      expect(deviceSupport.models.defaultModel, 'small');
    });
  });

  group('LanguageDetectionResult', () {
    test('creates instance with language and probabilities', () {
      // Arrange & Act
      const result = LanguageDetectionResult(
        language: 'en',
        probabilities: {'en': 0.95, 'ja': 0.05},
      );

      // Assert
      expect(result.language, 'en');
      expect(result.probabilities, {'en': 0.95, 'ja': 0.05});
    });

    test('toJson returns correct map', () {
      // Arrange
      const result = LanguageDetectionResult(
        language: 'ja',
        probabilities: {'ja': 0.8, 'en': 0.2},
      );

      // Act
      final json = result.toJson();

      // Assert
      expect(json['language'], 'ja');
      expect(json['probabilities'], {'ja': 0.8, 'en': 0.2});
    });

    test('fromJson creates instance correctly', () {
      // Arrange
      final json = {
        'language': 'fr',
        'probabilities': {'fr': 0.9, 'en': 0.1},
      };

      // Act
      final result = LanguageDetectionResult.fromJson(json);

      // Assert
      expect(result.language, 'fr');
      expect(result.probabilities, {'fr': 0.9, 'en': 0.1});
    });
  });

  group('ModelSupport', () {
    test('creates instance with all parameters', () {
      // Arrange & Act
      const modelSupport = ModelSupport(
        defaultModel: 'base',
        supported: ['tiny', 'base', 'small'],
        disabled: ['large'],
      );

      // Assert
      expect(modelSupport.defaultModel, 'base');
      expect(modelSupport.supported, ['tiny', 'base', 'small']);
      expect(modelSupport.disabled, ['large']);
    });

    test('toJson returns correct map', () {
      // Arrange
      const modelSupport = ModelSupport(
        defaultModel: 'tiny',
        supported: ['tiny'],
        disabled: ['base', 'small', 'medium', 'large'],
      );

      // Act
      final json = modelSupport.toJson();

      // Assert
      expect(json['default'], 'tiny');
      expect(json['supported'], ['tiny']);
      expect(json['disabled'], ['base', 'small', 'medium', 'large']);
    });

    test('fromJson creates instance correctly', () {
      // Arrange
      final json = {
        'default': 'medium',
        'supported': ['tiny', 'base', 'small', 'medium'],
        'disabled': ['large'],
      };

      // Act
      final modelSupport = ModelSupport.fromJson(json);

      // Assert
      expect(modelSupport.defaultModel, 'medium');
      expect(modelSupport.supported, ['tiny', 'base', 'small', 'medium']);
      expect(modelSupport.disabled, ['large']);
    });
  });

  group('ModelSupportConfig', () {
    test('creates instance with all parameters', () {
      // Arrange & Act
      final config = ModelSupportConfig(
        repoName: 'test/repo',
        repoVersion: '1.0.0',
        deviceSupports: [
          DeviceSupport(
            chips: 'A12',
            identifiers: ['iPhone11,8'],
            models: const ModelSupport(
              defaultModel: 'tiny',
              supported: ['tiny'],
              disabled: [],
            ),
          ),
        ],
        knownModels: ['tiny', 'base'],
        defaultSupport: const ModelSupport(
          defaultModel: 'tiny',
          supported: ['tiny'],
          disabled: [],
        ),
      );

      // Assert
      expect(config.repoName, 'test/repo');
      expect(config.repoVersion, '1.0.0');
      expect(config.deviceSupports, hasLength(1));
      expect(config.knownModels, ['tiny', 'base']);
      expect(config.defaultSupport.defaultModel, 'tiny');
    });

    test('toJson returns correct map', () {
      // Arrange
      final config = ModelSupportConfig(
        repoName: 'argmaxinc/whisperkit-coreml',
        repoVersion: '2.0.0',
        deviceSupports: [],
        knownModels: ['tiny', 'base', 'small'],
        defaultSupport: const ModelSupport(
          defaultModel: 'base',
          supported: ['tiny', 'base'],
          disabled: ['small'],
        ),
      );

      // Act
      final json = config.toJson();

      // Assert
      // Note: repoName is not included in toJson output
      expect(json['repoVersion'], '2.0.0');
      expect(json['deviceSupports'], []);
      expect(json['knownModels'], ['tiny', 'base', 'small']);
      expect(json['defaultSupport'], isA<Map<String, dynamic>>());
    });

    test('fromJson creates instance correctly', () {
      // Arrange
      final json = {
        'name': 'custom/repo',
        'repoVersion': '1.5.0',
        'deviceSupports': [],
        'knownModels': ['tiny'],
        'defaultSupport': {
          'default': 'tiny',
          'supported': ['tiny'],
          'disabled': [],
        },
      };

      // Act
      final config = ModelSupportConfig.fromJson(json);

      // Assert
      expect(config.repoName, 'custom/repo');
      expect(config.repoVersion, '1.5.0');
      expect(config.deviceSupports, isEmpty);
      expect(config.knownModels, ['tiny']);
      expect(config.defaultSupport.defaultModel, 'tiny');
    });
  });

  group('WordTiming', () {
    test('creates instance with word and timing', () {
      // Arrange & Act
      const wordTiming = WordTiming(
        word: 'hello',
        tokens: [1, 2, 3],
        start: 0.5,
        end: 1.0,
        probability: 0.95,
      );

      // Assert
      expect(wordTiming.word, 'hello');
      expect(wordTiming.start, 0.5);
      expect(wordTiming.end, 1.0);
      expect(wordTiming.probability, 0.95);
    });

    test('toJson returns correct map', () {
      // Arrange
      const wordTiming = WordTiming(
        word: 'world',
        tokens: [4, 5],
        start: 1.0,
        end: 1.5,
        probability: 0.9,
      );

      // Act
      final json = wordTiming.toJson();

      // Assert
      expect(json['word'], 'world');
      expect(json['start'], 1.0);
      expect(json['end'], 1.5);
      expect(json['probability'], 0.9);
    });

    test('fromJson creates instance correctly', () {
      // Arrange
      final json = {
        'word': 'test',
        'tokens': [1, 2, 3],
        'start': 2.0,
        'end': 2.5,
        'probability': 0.85,
      };

      // Act
      final wordTiming = WordTiming.fromJson(json);

      // Assert
      expect(wordTiming.word, 'test');
      expect(wordTiming.start, 2.0);
      expect(wordTiming.end, 2.5);
      expect(wordTiming.probability, 0.85);
    });
  });

  group('TranscriptionSegment', () {
    test('creates instance with required parameters', () {
      // Arrange & Act
      const segment = TranscriptionSegment(
        id: 0,
        seek: 100,
        text: 'Hello world',
        start: 0.0,
        end: 2.0,
        tokens: [1, 2, 3],
      );

      // Assert
      expect(segment.id, 0);
      expect(segment.seek, 100);
      expect(segment.text, 'Hello world');
      expect(segment.start, 0.0);
      expect(segment.end, 2.0);
      expect(segment.tokens, [1, 2, 3]);
    });

    test('creates instance with optional parameters', () {
      // Arrange & Act
      const segment = TranscriptionSegment(
        id: 1,
        seek: 200,
        text: 'Test segment',
        start: 2.0,
        end: 4.0,
        tokens: [4, 5, 6],
        temperature: 0.8,
        avgLogprob: -0.5,
        compressionRatio: 1.2,
        noSpeechProb: 0.1,
        words: [
          WordTiming(
            word: 'Test',
            tokens: [1],
            start: 2.0,
            end: 2.5,
            probability: 0.9,
          ),
          WordTiming(
            word: 'segment',
            tokens: [2],
            start: 2.5,
            end: 4.0,
            probability: 0.95,
          ),
        ],
      );

      // Assert
      expect(segment.temperature, 0.8);
      expect(segment.avgLogprob, -0.5);
      expect(segment.compressionRatio, 1.2);
      expect(segment.noSpeechProb, 0.1);
      expect(segment.words, hasLength(2));
    });

    test('toJson returns correct map', () {
      // Arrange
      const segment = TranscriptionSegment(
        id: 0,
        seek: 0,
        text: 'Test',
        start: 0.0,
        end: 1.0,
        tokens: [1],
        temperature: 1.0,
      );

      // Act
      final json = segment.toJson();

      // Assert
      expect(json['id'], 0);
      expect(json['seek'], 0);
      expect(json['text'], 'Test');
      expect(json['start'], 0.0);
      expect(json['end'], 1.0);
      expect(json['tokens'], [1]);
      expect(json['temperature'], 1.0);
    });

    test('fromJson creates instance correctly', () {
      // Arrange
      final json = {
        'id': 2,
        'seek': 300,
        'text': 'Another test',
        'start': 4.0,
        'end': 6.0,
        'tokens': [7, 8, 9],
        'temperature': 0.9,
        'avgLogprob': -0.3,
        'compressionRatio': 1.1,
        'noSpeechProb': 0.05,
      };

      // Act
      final segment = TranscriptionSegment.fromJson(json);

      // Assert
      expect(segment.id, 2);
      expect(segment.seek, 300);
      expect(segment.text, 'Another test');
      expect(segment.start, 4.0);
      expect(segment.end, 6.0);
      expect(segment.tokens, [7, 8, 9]);
      expect(segment.temperature, 0.9);
      expect(segment.avgLogprob, -0.3);
      expect(segment.compressionRatio, 1.1);
      expect(segment.noSpeechProb, 0.05);
    });
  });

  group('TranscriptionTimings', () {
    test('creates instance with default values', () {
      // Arrange & Act
      const timings = TranscriptionTimings();

      // Assert
      expect(timings.pipelineStart, 0.0);
      expect(timings.firstTokenTime, 0.0);
      expect(timings.inputAudioSeconds, 0.001);
      expect(timings.audioLoading, 0.0);
      expect(timings.audioProcessing, 0.0);
      expect(timings.encoding, 0.0);
      expect(timings.decodingLoop, 0.0);
      expect(timings.fullPipeline, 0.0);
    });

    test('creates instance with custom values', () {
      // Arrange & Act
      const timings = TranscriptionTimings(
        pipelineStart: 1.0,
        firstTokenTime: 0.5,
        inputAudioSeconds: 10.0,
        audioLoading: 0.1,
        audioProcessing: 0.2,
        encoding: 0.3,
        decodingLoop: 0.4,
        fullPipeline: 2.0,
      );

      // Assert
      expect(timings.pipelineStart, 1.0);
      expect(timings.firstTokenTime, 0.5);
      expect(timings.inputAudioSeconds, 10.0);
      expect(timings.audioLoading, 0.1);
      expect(timings.audioProcessing, 0.2);
      expect(timings.encoding, 0.3);
      expect(timings.decodingLoop, 0.4);
      expect(timings.fullPipeline, 2.0);
    });

    test('toJson returns correct map', () {
      // Arrange
      const timings = TranscriptionTimings(fullPipeline: 1.5, encoding: 0.2);

      // Act
      final json = timings.toJson();

      // Assert
      expect(json['fullPipeline'], 1.5);
      expect(json['encoding'], 0.2);
      expect(json['pipelineStart'], 0.0);
    });

    test('fromJson creates instance correctly', () {
      // Arrange
      final json = {
        'pipelineStart': 0.5,
        'firstTokenTime': 0.3,
        'fullPipeline': 2.5,
      };

      // Act
      final timings = TranscriptionTimings.fromJson(json);

      // Assert
      expect(timings.pipelineStart, 0.5);
      expect(timings.firstTokenTime, 0.3);
      expect(timings.fullPipeline, 2.5);
      expect(timings.inputAudioSeconds, 0.001);
    });
  });
}
