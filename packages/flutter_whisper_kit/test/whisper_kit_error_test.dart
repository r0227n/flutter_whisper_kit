import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

void main() {
  group('WhisperKitError', () {
    group('fromPlatformException', () {
      test('creates ModelLoadingFailedError for error codes 1000-1999', () {
        // Arrange
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=1234 "Model loading failed"',
          message: 'Failed to load model',
          details: {'modelName': 'tiny'},
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<ModelLoadingFailedError>());
        expect(error.message, 'Model loading failed');
        expect(error.details, {'modelName': 'tiny'});
      });

      test('creates TranscriptionFailedError for error codes 2000-2999', () {
        // Arrange
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=2001 "Transcription failed"',
          message: 'Failed to transcribe',
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<TranscriptionFailedError>());
        expect(error.message, 'Transcription failed');
      });

      test('creates RecordingFailedError for error codes 3000-3999', () {
        // Arrange
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=3500 "Recording failed"',
          message: 'Failed to record',
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<RecordingFailedError>());
        expect(error.message, 'Recording failed');
      });

      test('creates PermissionDeniedError for error codes 4000-4999', () {
        // Arrange
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=4001 "Permission denied"',
          message: 'Microphone permission denied',
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<PermissionDeniedError>());
        expect(error.message, 'Permission denied');
      });

      test('creates InvalidArgumentsError for error codes 5000-5999', () {
        // Arrange
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=5555 "Invalid arguments"',
          message: 'Invalid parameters',
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<InvalidArgumentsError>());
        expect(error.message, 'Invalid arguments');
      });

      test('creates UnknownError for unhandled numeric error codes', () {
        // Arrange
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=9999 "Unknown error"',
          message: 'Something went wrong',
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<UnknownError>());
        expect(error.message, 'Unknown error');
      });

      test('creates UnknownError for non-WhisperKitError domain', () {
        // Arrange
        final platformException = PlatformException(
          code: 'Domain=OtherError Code=1234 "Other error"',
          message: 'Different domain error',
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<UnknownError>());
        expect(error.message, 'Different domain error');
      });

      test('creates UnknownError for non-NSError format', () {
        // Arrange
        final platformException = PlatformException(
          code: 'INVALID_ARGUMENT',
          message: 'Invalid argument provided',
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<UnknownError>());
        expect(error.message, 'Invalid argument provided');
      });

      test('handles null message in PlatformException', () {
        // Arrange
        final platformException = PlatformException(
          code: 'UNKNOWN_ERROR',
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<UnknownError>());
        expect(error.message, 'Unknown error');
      });

      test('preserves details from PlatformException', () {
        // Arrange
        final details = {
          'filePath': '/path/to/audio.wav',
          'errorCode': 1234,
        };
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=1234 "Test error"',
          message: 'Test message',
          details: details,
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error.details, details);
      });
    });

    group('toString', () {
      test('includes error type and message', () {
        // Arrange
        const error = ModelLoadingFailedError(
          message: 'Failed to load model',
        );

        // Act
        final result = error.toString();

        // Assert
        expect(result, 'ModelLoadingFailedError: Failed to load model');
      });

      test('works for all error types', () {
        // Arrange
        final errors = [
          const TranscriptionFailedError(message: 'Transcription failed'),
          const RecordingFailedError(message: 'Recording failed'),
          const InvalidArgumentsError(message: 'Invalid arguments'),
          const PermissionDeniedError(message: 'Permission denied'),
          const UnknownError(message: 'Unknown error'),
        ];

        // Act & Assert
        for (final error in errors) {
          final result = error.toString();
          expect(result, contains(error.runtimeType.toString()));
          expect(result, contains(error.message));
        }
      });
    });

    group('error boundary edge cases', () {
      test('correctly handles boundary error code 1999', () {
        // Arrange
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=1999 "Boundary test"',
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<ModelLoadingFailedError>());
      });

      test('correctly handles boundary error code 2000', () {
        // Arrange
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=2000 "Boundary test"',
        );

        // Act
        final error = WhisperKitError.fromPlatformException(platformException);

        // Assert
        expect(error, isA<TranscriptionFailedError>());
      });
    });
  });
}