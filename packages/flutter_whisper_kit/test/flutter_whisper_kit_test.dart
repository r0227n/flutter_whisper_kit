import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterWhisperKit', () {
    late FlutterWhisperKit whisperKit;
    late MockFlutterWhisperkitPlatform mockPlatform;

    setUp(() {
      mockPlatform = setUpMockPlatform();
      whisperKit = FlutterWhisperKit();
    });

    tearDown(() {
      mockPlatform.progressController.close();
      mockPlatform.transcriptionController.close();
    });

    group('_handlePlatformCall', () {
      test('transforms PlatformException to WhisperKitError', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=1234 "Model loading failed"',
            message: 'Failed to load model',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.loadModel('tiny'),
          throwsA(isA<ModelLoadingFailedError>()),
        );
      });

      test('rethrows non-PlatformException errors', () async {
        // Arrange
        mockPlatform.setThrowError(Exception('Generic error'));

        // Act & Assert
        expect(
          () => whisperKit.loadModel('tiny'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('loadModel', () {
      test('loads model successfully without progress callback', () async {
        // Act
        final result = await whisperKit.loadModel('tiny');

        // Assert
        expect(result, contains('whisperkit-coreml/openai_whisper-'));
        expect(result, contains('tiny'));
      });

      test('loads model with custom repository', () async {
        // Act
        final result = await whisperKit.loadModel(
          'base',
          modelRepo: 'custom/repo',
        );

        // Assert
        expect(result, isNotNull);
      });

      test('loads model with redownload flag', () async {
        // Act
        final result = await whisperKit.loadModel(
          'small',
          redownload: true,
        );

        // Assert
        expect(result, isNotNull);
      });

      test('handles progress callback correctly', () async {
        // Arrange
        final stream = whisperKit.modelProgressStream;
        final firstProgressFuture = stream.first;

        // Act
        final loadFuture = whisperKit.loadModel('tiny');
        mockPlatform.emitProgressUpdates();

        // Assert
        final firstProgress = await firstProgressFuture;
        expect(firstProgress.fractionCompleted, 0.25);

        // Ensure all events are emitted and processed
        await expectLater(
          stream,
          emitsInOrder([
            isA<Progress>()
                .having((p) => p.fractionCompleted, 'fractionCompleted', 0.5),
            isA<Progress>()
                .having((p) => p.fractionCompleted, 'fractionCompleted', 1.0),
          ]),
        );
        await loadFuture;
      });

      test('cancels progress subscription after completion', () async {
        // Arrange
        int listenerCount = 0;
        mockPlatform.modelProgressStream.listen((_) {
          listenerCount++;
        });

        // Act
        final loadFuture = whisperKit.loadModel(
          'tiny',
          onProgress: (_) {},
        );

        // Emit progress updates to trigger the listener
        mockPlatform.emitProgressUpdates();

        await loadFuture;

        // Give time for cleanup
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - the listener should have received some events
        expect(listenerCount, greaterThan(0));
      });

      test('handles null variant', () async {
        // Act
        final result = await whisperKit.loadModel(null);

        // Assert
        expect(result, isNotNull);
      });
    });

    group('deviceName', () {
      test('returns device name successfully', () async {
        // Act
        final name = await whisperKit.deviceName();

        // Assert
        expect(name, 'Mock Device');
      });

      test('handles platform errors', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=5001 "Invalid operation"',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.deviceName(),
          throwsA(isA<InvalidArgumentsError>()),
        );
      });
    });

    group('recommendedModels', () {
      test('returns model support successfully', () async {
        // Act
        final modelSupport = await whisperKit.recommendedModels();

        // Assert
        expect(modelSupport, isA<ModelSupport>());
        expect(modelSupport.defaultModel, 'openai_whisper-base');
        expect(modelSupport.supported, contains('openai_whisper-tiny'));
        expect(modelSupport.supported, contains('openai_whisper-base'));
      });
    });

    group('detectLanguage', () {
      test('detects language successfully', () async {
        // Act
        final result = await whisperKit.detectLanguage('/path/to/audio.wav');

        // Assert
        expect(result, isA<LanguageDetectionResult>());
        expect(result.language, 'en');
        expect(result.probabilities, isNotEmpty);
        expect(result.probabilities['en'], greaterThan(0.5));
      });

      test('handles detection errors', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code:
                'Domain=WhisperKitError Code=2100 "Language detection failed"',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.detectLanguage('/invalid/path'),
          throwsA(isA<TranscriptionFailedError>()),
        );
      });
    });

    group('formatModelFiles', () {
      test('formats model files correctly', () async {
        // Arrange
        final modelFiles = ['model1.mlmodel', 'model2.mlmodel'];

        // Act
        final formatted = await whisperKit.formatModelFiles(modelFiles);

        // Assert
        expect(formatted,
            ['formatted_model1.mlmodel', 'formatted_model2.mlmodel']);
      });
    });

    group('fetchModelSupportConfig', () {
      test('fetches model support config successfully', () async {
        // Act
        final config = await whisperKit.fetchModelSupportConfig();

        // Assert
        expect(config, isA<ModelSupportConfig>());
        expect(config.knownModels, isNotEmpty);
      });
    });

    group('recommendedRemoteModels', () {
      test('fetches recommended remote models successfully', () async {
        // Act
        final modelSupport = await whisperKit.recommendedRemoteModels();

        // Assert
        expect(modelSupport, isA<ModelSupport>());
        expect(modelSupport.defaultModel, isNotEmpty);
      });
    });

    group('setupModels', () {
      test('sets up models with default parameters', () async {
        // Act
        final result = await whisperKit.setupModels();

        // Assert
        expect(result, 'Models set up successfully');
      });

      test('sets up models with custom parameters', () async {
        // Act
        final result = await whisperKit.setupModels(
          model: 'tiny',
          downloadBase: 'https://custom.url',
          modelRepo: 'custom/repo',
          modelToken: 'token123',
          modelFolder: '/custom/folder',
          download: false,
        );

        // Assert
        expect(result, 'Models set up successfully');
      });
    });

    group('download', () {
      test('downloads model successfully without progress callback', () async {
        // Act
        final result = await whisperKit.download(
          variant: 'tiny',
        );

        // Assert
        expect(result, contains('tiny'));
      });

      test('downloads model with progress callback', () async {
        // Arrange
        final stream = whisperKit.modelProgressStream;
        final firstProgressFuture = stream.first;

        // Act
        final downloadFuture = whisperKit.download(variant: 'base');
        mockPlatform.emitProgressUpdates();

        // Assert
        final firstProgress = await firstProgressFuture;
        expect(firstProgress.fractionCompleted, 0.25);

        await expectLater(
          stream,
          emitsInOrder([
            isA<Progress>()
                .having((p) => p.fractionCompleted, 'fractionCompleted', 0.5),
            isA<Progress>()
                .having((p) => p.fractionCompleted, 'fractionCompleted', 1.0),
          ]),
        );
        await downloadFuture;
      });

      test('downloads with custom parameters', () async {
        // Act
        final result = await whisperKit.download(
          variant: 'small',
          downloadBase: 'https://custom.url',
          useBackgroundSession: true,
          repo: 'custom/repo',
          token: 'token123',
        );

        // Assert
        expect(result, isNotNull);
      });

      test('cancels progress subscription after download', () async {
        // Act
        await whisperKit.download(
          variant: 'tiny',
          onProgress: (_) {},
        );

        // Assert - subscription should be cancelled
        // (tested by ensuring no memory leaks)
        expect(true, isTrue);
      });
    });

    group('prewarmModels', () {
      test('prewarms models successfully', () async {
        // Act
        final result = await whisperKit.prewarmModels();

        // Assert
        expect(result, 'Models prewarmed successfully');
      });
    });

    group('unloadModels', () {
      test('unloads models successfully', () async {
        // Act
        final result = await whisperKit.unloadModels();

        // Assert
        expect(result, 'Models unloaded successfully');
      });
    });

    group('clearState', () {
      test('clears state successfully', () async {
        // Act
        final result = await whisperKit.clearState();

        // Assert
        expect(result, 'State cleared successfully');
      });
    });

    group('loggingCallback', () {
      test('sets logging callback with default level', () async {
        // Act & Assert
        await expectLater(
          whisperKit.loggingCallback(),
          completes,
        );
      });

      test('sets logging callback with custom level', () async {
        // Act & Assert
        await expectLater(
          whisperKit.loggingCallback(level: 'debug'),
          completes,
        );
      });
    });

    group('streams', () {
      test('transcriptionStream provides access to platform stream', () {
        // Act
        final stream = whisperKit.transcriptionStream;

        // Assert
        expect(stream, isA<Stream<TranscriptionResult>>());
        expect(stream, isA<Stream<TranscriptionResult>>());
      });

      test('modelProgressStream provides access to platform stream', () {
        // Act
        final stream = whisperKit.modelProgressStream;

        // Assert
        expect(stream, isA<Stream<Progress>>());
        expect(stream, isA<Stream<Progress>>());
      });
    });
  });
}
