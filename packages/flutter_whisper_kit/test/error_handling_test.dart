import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

import 'test_utils/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Error Handling Scenarios', () {
    late FlutterWhisperKit whisperKit;
    late MockFlutterWhisperkitPlatform mockPlatform;

    setUp(() {
      mockPlatform = setUpMockPlatform();
      whisperKit = FlutterWhisperKit();
    });

    group('Model Loading Errors', () {
      test('handles model not found error', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=1001 "Model not found"',
            message: 'The specified model variant could not be found',
            details: {'variant': 'invalid-model'},
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.loadModel('invalid-model'),
          throwsA(allOf(
            isA<ModelLoadingFailedError>(),
            predicate<ModelLoadingFailedError>(
              (error) => error.message == 'Model not found',
            ),
            predicate<ModelLoadingFailedError>(
              (error) => error.details != null && 
                         error.details['variant'] == 'invalid-model',
            ),
          )),
        );
      });

      test('handles model download failure', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=1500 "Download failed"',
            message: 'Failed to download model from repository',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.download(variant: 'large'),
          throwsA(isA<ModelLoadingFailedError>()),
        );
      });

      test('handles insufficient storage error', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=1800 "Insufficient storage"',
            message: 'Not enough storage space to download model',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.loadModel('large', redownload: true),
          throwsA(isA<ModelLoadingFailedError>()),
        );
      });
    });

    group('Transcription Errors', () {
      test('handles invalid audio file error', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=2100 "Invalid audio file"',
            message: 'The audio file format is not supported',
            details: {'filePath': '/invalid/path.xyz'},
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.transcribeFromFile('/invalid/path.xyz'),
          throwsA(isA<TranscriptionFailedError>()),
        );
      });

      test('handles transcription timeout error', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=2200 "Transcription timeout"',
            message: 'Transcription took too long to complete',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.transcribeFromFile('/very/long/audio.wav'),
          throwsA(isA<TranscriptionFailedError>()),
        );
      });

      test('handles language detection failure', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=2300 "Language detection failed"',
            message: 'Unable to detect language from audio',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.detectLanguage('/unclear/audio.wav'),
          throwsA(isA<TranscriptionFailedError>()),
        );
      });
    });

    group('Recording Errors', () {
      test('handles microphone unavailable error', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=3100 "Microphone unavailable"',
            message: 'Microphone is being used by another application',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.startRecording(),
          throwsA(isA<RecordingFailedError>()),
        );
      });

      test('handles recording interruption error', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=3200 "Recording interrupted"',
            message: 'Recording was interrupted by system event',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.stopRecording(),
          throwsA(isA<RecordingFailedError>()),
        );
      });

      test('handles audio session configuration error', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=3300 "Audio session error"',
            message: 'Failed to configure audio session',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.startRecording(loop: false),
          throwsA(isA<RecordingFailedError>()),
        );
      });
    });

    group('Permission Errors', () {
      test('handles microphone permission denied', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=4100 "Microphone permission denied"',
            message: 'Microphone permission is required for recording',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.startRecording(),
          throwsA(isA<PermissionDeniedError>()),
        );
      });

      test('handles file access permission denied', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=4200 "File access denied"',
            message: 'Permission denied to access the audio file',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.transcribeFromFile('/protected/file.wav'),
          throwsA(isA<PermissionDeniedError>()),
        );
      });

      test('handles storage permission denied', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=4300 "Storage permission denied"',
            message: 'Permission denied to write model files',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.loadModel('base'),
          throwsA(isA<PermissionDeniedError>()),
        );
      });
    });

    group('Invalid Arguments Errors', () {
      test('handles invalid model variant', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=5100 "Invalid model variant"',
            message: 'The specified model variant is not valid',
            details: {'variant': 'super-large'},
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.loadModel('super-large'),
          throwsA(isA<InvalidArgumentsError>()),
        );
      });

      test('handles invalid decoding options', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=5200 "Invalid decoding options"',
            message: 'Temperature value must be between 0.0 and 1.0',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.transcribeFromFile(
            'test.wav',
            options: const DecodingOptions(temperature: 2.0),
          ),
          throwsA(isA<InvalidArgumentsError>()),
        );
      });

      test('handles empty file path', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=5300 "Empty file path"',
            message: 'File path cannot be empty',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.transcribeFromFile(''),
          throwsA(isA<InvalidArgumentsError>()),
        );
      });

      test('handles invalid repository URL', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=5400 "Invalid repository URL"',
            message: 'The repository URL format is invalid',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.fetchAvailableModels(modelRepo: 'invalid-url'),
          throwsA(isA<InvalidArgumentsError>()),
        );
      });
    });

    group('Network and Connectivity Errors', () {
      test('handles network unavailable during model download', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=6100 "Network unavailable"',
            message: 'No internet connection available',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.download(variant: 'base'),
          throwsA(isA<UnknownError>()),
        );
      });

      test('handles repository server error', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=6200 "Server error"',
            message: 'Repository server returned error 500',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.fetchAvailableModels(),
          throwsA(isA<UnknownError>()),
        );
      });
    });

    group('System Resource Errors', () {
      test('handles insufficient memory for model loading', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=1900 "Insufficient memory"',
            message: 'Not enough memory to load the model',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.prewarmModels(),
          throwsA(isA<ModelLoadingFailedError>()),
        );
      });

      test('handles system interruption during transcription', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=2400 "System interruption"',
            message: 'Transcription was interrupted by system',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.clearState(),
          throwsA(isA<TranscriptionFailedError>()),
        );
      });
    });

    group('Edge Cases and Unknown Errors', () {
      test('handles malformed error code', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'MALFORMED_ERROR',
            message: 'Something went wrong',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.deviceName(),
          throwsA(isA<UnknownError>()),
        );
      });

      test('handles error without message', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=9999 "Mystery error"',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.setupModels(),
          throwsA(allOf(
            isA<UnknownError>(),
            predicate<UnknownError>((error) => error.message == 'Mystery error'),
          )),
        );
      });

      test('handles non-WhisperKit domain error', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=SystemError Code=1000 "System error"',
            message: 'A system error occurred',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.loggingCallback(level: 'debug'),
          throwsA(isA<UnknownError>()),
        );
      });

      test('handles boundary error code 999', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=999 "Boundary test"',
            message: 'Testing boundary conditions',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.unloadModels(),
          throwsA(isA<UnknownError>()),
        );
      });

      test('handles error code exactly at boundary 6000', () async {
        // Arrange
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=6000 "Boundary test"',
            message: 'Testing upper boundary',
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.formatModelFiles(['test.mlmodel']),
          throwsA(isA<UnknownError>()),
        );
      });
    });

    group('Error Recovery Scenarios', () {
      test('can continue operation after error', () async {
        // Arrange - first call throws error
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=1000 "Temporary error"',
          ),
        );

        // Act & Assert - first call fails
        expect(
          () => whisperKit.deviceName(),
          throwsA(isA<ModelLoadingFailedError>()),
        );

        // Act & Assert - second call succeeds (error was reset)
        final deviceName = await whisperKit.deviceName();
        expect(deviceName, 'Mock Device');
      });

      test('error details are preserved across conversions', () async {
        // Arrange
        final originalDetails = {
          'errorCode': 1234,
          'context': 'test context',
          'additionalInfo': ['info1', 'info2'],
        };
        
        mockPlatform.setThrowError(
          PlatformException(
            code: 'Domain=WhisperKitError Code=2000 "Detailed error"',
            message: 'Error with details',
            details: originalDetails,
          ),
        );

        // Act & Assert
        expect(
          () => whisperKit.recommendedModels(),
          throwsA(allOf(
            isA<TranscriptionFailedError>(),
            predicate<TranscriptionFailedError>(
              (error) => error.details == originalDetails,
            ),
          )),
        );
      });
    });
  });
}