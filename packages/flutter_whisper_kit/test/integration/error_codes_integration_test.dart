import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_platform_interface.dart';

import '../core/test_utils/mock_platform.dart';

void main() {
  late MockFlutterWhisperKitPlatform mockPlatform;
  late FlutterWhisperKit whisperKit;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockPlatform = MockFlutterWhisperKitPlatform();
    FlutterWhisperKitPlatform.instance = mockPlatform;
    whisperKit = FlutterWhisperKit();
  });

  group('Error codes integration', () {
    test(
      'should use standardized error codes for model loading failures',
      () async {
        // Given
        mockPlatform.setShouldThrowOnLoadModel(true);
        mockPlatform.setErrorCode(ErrorCode.modelNotFound);

        // When
        final result = await whisperKit.loadModelWithResult(
          'nonexistent-model',
        );

        // Then
        result.when(
          success: (_) => fail('Should not succeed'),
          failure: (exception) {
            expect(exception.code, ErrorCode.modelNotFound);
            expect(exception.message, contains('Model not found'));
            expect(
              ErrorCategory.fromCode(exception.code),
              ErrorCategory.initialization,
            );
            expect(ErrorCode.isRecoverable(exception.code), false);
            expect(
              ErrorCode.getSuggestedAction(exception.code),
              contains('Check model path'),
            );
          },
        );
      },
    );

    test(
      'should use standardized error codes for transcription failures',
      () async {
        // Given
        mockPlatform.setShouldThrowOnTranscribeFile(true);
        mockPlatform.setErrorCode(ErrorCode.audioProcessingError);

        // When
        final result = await whisperKit.transcribeFileWithResult(
          '/path/to/audio.mp3',
        );

        // Then
        result.when(
          success: (_) => fail('Should not succeed'),
          failure: (exception) {
            expect(exception.code, ErrorCode.audioProcessingError);
            expect(
              ErrorCategory.fromCode(exception.code),
              ErrorCategory.runtime,
            );
            expect(ErrorCode.isRecoverable(exception.code), true);
          },
        );
      },
    );

    test('should handle network errors with appropriate codes', () async {
      // Given
      mockPlatform.setShouldThrowOnLoadModel(true);
      mockPlatform.setErrorCode(ErrorCode.networkTimeout);

      // When
      final result = await whisperKit.loadModelWithResult('model-to-download');

      // Then
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (exception) {
          expect(exception.code, ErrorCode.networkTimeout);
          expect(ErrorCategory.fromCode(exception.code), ErrorCategory.network);
          expect(ErrorCode.isRecoverable(exception.code), true);
          expect(
            ErrorCode.getSuggestedAction(exception.code),
            contains('Check network connection'),
          );
        },
      );
    });

    test('should handle permission errors with appropriate codes', () async {
      // Given
      mockPlatform.setShouldThrowOnStartRecording(true);
      mockPlatform.setErrorCode(ErrorCode.microphonePermissionDenied);

      // When
      try {
        await whisperKit.startRecording();
        fail('Should throw error');
      } on WhisperKitError catch (e) {
        // Then - now we catch the typed error and check its errorCode property
        expect(e.code, ErrorCode.microphonePermissionDenied);
        expect(ErrorCategory.fromCode(e.code), ErrorCategory.permission);
        expect(
          ErrorCode.getSuggestedAction(e.code),
          contains('Grant microphone permission'),
        );
      }
    });

    test('should handle validation errors with appropriate codes', () async {
      // Given
      mockPlatform.setShouldThrowOnTranscribeFile(true);
      mockPlatform.setErrorCode(ErrorCode.invalidAudioFormat);

      // When
      final result = await whisperKit.transcribeFileWithResult(
        '/path/to/invalid.txt',
      );

      // Then
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (exception) {
          expect(exception.code, ErrorCode.invalidAudioFormat);
          expect(
            ErrorCategory.fromCode(exception.code),
            ErrorCategory.validation,
          );
          expect(
            ErrorCode.getSuggestedAction(exception.code),
            contains('Convert audio to supported format'),
          );
        },
      );
    });

    test(
      'should create errors with custom messages while preserving codes',
      () {
        // Given
        final customError = WhisperKitError.fromCode(
          ErrorCode.transcriptionFailed,
          'Custom transcription error: timeout after 30 seconds',
        );

        // Then
        expect(customError.code, ErrorCode.transcriptionFailed);
        expect(customError.message, contains('Custom transcription error'));
        expect(ErrorCategory.fromCode(customError.code), ErrorCategory.runtime);
      },
    );

    test('should provide consistent error information across the API', () {
      // Test that all error codes have descriptions
      final testCodes = [
        ErrorCode.modelNotFound,
        ErrorCode.transcriptionFailed,
        ErrorCode.networkTimeout,
        ErrorCode.microphonePermissionDenied,
        ErrorCode.invalidAudioFormat,
      ];

      for (final code in testCodes) {
        expect(ErrorCode.getDescription(code), isNotEmpty);
        expect(ErrorCategory.fromCode(code), isNotNull);
        expect(ErrorCode.getSuggestedAction(code), isNotEmpty);
      }
    });
  });
}
