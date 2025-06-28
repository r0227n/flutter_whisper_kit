import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/whisper_kit_error.dart';

void main() {
  group('WhisperKitError', () {
    test('should have correct properties', () {
      const error = WhisperKitError(
        code: 1001,
        message: 'Test error',
        details: {'key': 'value'},
      );

      expect(error.code, equals(1001));
      expect(error.message, equals('Test error'));
      expect(error.details, equals({'key': 'value'}));
    });

    test('toString should format correctly', () {
      const error = WhisperKitError(
        code: 2001,
        message: 'Transcription failed',
      );

      expect(error.toString(),
          equals('WhisperKitError(2001): Transcription failed'));
    });
  });

  group('WhisperKitErrorFactory', () {
    group('fromPlatformException with NSError format', () {
      test('should parse NSError format and extract code and message', () {
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=1234 "Model loading failed"',
          message: 'Failed to load model',
          details: {'modelName': 'tiny'},
        );

        final error =
            WhisperKitErrorFactory.fromPlatformException(platformException);

        expect(error.code, equals(1234));
        expect(error.message, equals('Model loading failed'));
        expect(error.details, equals({'modelName': 'tiny'}));
      });

      test('should parse various NSError codes correctly', () {
        final testCases = [
          (code: 2001, message: 'Transcription failed'),
          (code: 3500, message: 'Recording failed'),
          (code: 4001, message: 'Permission denied'),
          (code: 5555, message: 'Invalid arguments'),
          (code: 9999, message: 'Unknown error'),
        ];

        for (final testCase in testCases) {
          final platformException = PlatformException(
            code:
                'Domain=WhisperKitError Code=${testCase.code} "${testCase.message}"',
            message: 'Fallback message',
          );

          final error =
              WhisperKitErrorFactory.fromPlatformException(platformException);

          expect(error.code, equals(testCase.code));
          expect(error.message, equals(testCase.message));
        }
      });

      test('should handle NSError with different domains', () {
        final platformException = PlatformException(
          code: 'Domain=OtherError Code=1234 "Other error"',
          message: 'Different domain error',
        );

        final error =
            WhisperKitErrorFactory.fromPlatformException(platformException);

        expect(error.code, equals(1234));
        expect(error.message, equals('Other error'));
      });

      test('should preserve details from PlatformException', () {
        final details = {
          'filePath': '/path/to/audio.wav',
          'errorCode': 1234,
        };
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=1234 "Test error"',
          message: 'Test message',
          details: details,
        );

        final error =
            WhisperKitErrorFactory.fromPlatformException(platformException);

        expect(error.details, equals(details));
      });
    });

    group('fromPlatformException without NSError format', () {
      test('should assign default error code based on message content', () {
        final testCases = [
          (message: 'Transcription failed somehow', expectedCode: 2001),
          (message: 'Permission denied for microphone', expectedCode: 4001),
          (message: 'Network connection failed', expectedCode: 3001),
          (message: 'Generic error occurred', expectedCode: 1000),
        ];

        for (final testCase in testCases) {
          final platformException = PlatformException(
            code: 'INVALID_ARGUMENT',
            message: testCase.message,
          );

          final error =
              WhisperKitErrorFactory.fromPlatformException(platformException);

          expect(error.code, equals(testCase.expectedCode));
          expect(error.message, equals(testCase.message));
        }
      });

      test('should handle null message in PlatformException', () {
        final platformException = PlatformException(
          code: 'UNKNOWN_ERROR',
        );

        final error =
            WhisperKitErrorFactory.fromPlatformException(platformException);

        expect(error.code, equals(1000));
        expect(error.message, equals('Unknown error'));
      });

      test('should handle non-standard error codes', () {
        final platformException = PlatformException(
          code: 'CUSTOM_ERROR_CODE',
          message: 'Custom error message',
          details: {'custom': 'data'},
        );

        final error =
            WhisperKitErrorFactory.fromPlatformException(platformException);

        expect(error.code, equals(1000));
        expect(error.message, equals('Custom error message'));
        expect(error.details, equals({'custom': 'data'}));
      });
    });
  });

  group('WhisperKitErrorType', () {
    group('fromPlatformException', () {
      test('creates ModelLoadingFailedError for error codes 1000-1999', () {
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=1234 "Model loading failed"',
          message: 'Failed to load model',
          details: {'modelName': 'tiny'},
        );

        final error =
            WhisperKitErrorType.fromPlatformException(platformException);

        expect(error, isA<ModelLoadingFailedError>());
        expect(error.message, equals('Model loading failed'));
        expect(error.details, equals({'modelName': 'tiny'}));
      });

      test('creates TranscriptionFailedError for error codes 2000-2999', () {
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=2001 "Transcription failed"',
          message: 'Failed to transcribe',
        );

        final error =
            WhisperKitErrorType.fromPlatformException(platformException);

        expect(error, isA<TranscriptionFailedError>());
        expect(error.message, equals('Transcription failed'));
      });

      test('creates RecordingFailedError for error codes 3000-3999', () {
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=3500 "Recording failed"',
          message: 'Failed to record',
        );

        final error =
            WhisperKitErrorType.fromPlatformException(platformException);

        expect(error, isA<RecordingFailedError>());
        expect(error.message, equals('Recording failed'));
      });

      test('creates PermissionDeniedError for error codes 4000-4999', () {
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=4001 "Permission denied"',
          message: 'Microphone permission denied',
        );

        final error =
            WhisperKitErrorType.fromPlatformException(platformException);

        expect(error, isA<PermissionDeniedError>());
        expect(error.message, equals('Permission denied'));
      });

      test('creates InvalidArgumentsError for error codes 5000-5999', () {
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=5555 "Invalid arguments"',
          message: 'Invalid parameters',
        );

        final error =
            WhisperKitErrorType.fromPlatformException(platformException);

        expect(error, isA<InvalidArgumentsError>());
        expect(error.message, equals('Invalid arguments'));
      });

      test('creates UnknownError for unhandled numeric error codes', () {
        final platformException = PlatformException(
          code: 'Domain=WhisperKitError Code=9999 "Unknown error"',
          message: 'Something went wrong',
        );

        final error =
            WhisperKitErrorType.fromPlatformException(platformException);

        expect(error, isA<UnknownError>());
        expect(error.message, equals('Unknown error'));
      });

      test('creates UnknownError for non-WhisperKitError domain', () {
        final platformException = PlatformException(
          code: 'Domain=OtherError Code=1234 "Other error"',
          message: 'Different domain error',
        );

        final error =
            WhisperKitErrorType.fromPlatformException(platformException);

        expect(error, isA<UnknownError>());
        expect(error.message, equals('Different domain error'));
      });

      test('creates UnknownError for non-NSError format', () {
        final platformException = PlatformException(
          code: 'INVALID_ARGUMENT',
          message: 'Invalid argument provided',
        );

        final error =
            WhisperKitErrorType.fromPlatformException(platformException);

        expect(error, isA<UnknownError>());
        expect(error.message, equals('Invalid argument provided'));
      });

      test('handles null message in PlatformException', () {
        final platformException = PlatformException(
          code: 'UNKNOWN_ERROR',
        );

        final error =
            WhisperKitErrorType.fromPlatformException(platformException);

        expect(error, isA<UnknownError>());
        expect(error.message, equals('Unknown error'));
      });

      test('correctly handles boundary error codes', () {
        final testCases = [
          (code: 1999, expectedType: ModelLoadingFailedError),
          (code: 2000, expectedType: TranscriptionFailedError),
          (code: 2999, expectedType: TranscriptionFailedError),
          (code: 3000, expectedType: RecordingFailedError),
        ];

        for (final testCase in testCases) {
          final platformException = PlatformException(
            code:
                'Domain=WhisperKitError Code=${testCase.code} "Boundary test"',
          );

          final error =
              WhisperKitErrorType.fromPlatformException(platformException);

          expect(error.runtimeType, equals(testCase.expectedType));
        }
      });
    });

    group('toString', () {
      test('includes error type and message for all error types', () {
        final errors = [
          const ModelLoadingFailedError(
              message: 'Failed to load model', errorCode: 1001),
          const TranscriptionFailedError(
              message: 'Transcription failed', errorCode: 2001),
          const RecordingFailedError(
              message: 'Recording failed', errorCode: 3001),
          const InvalidArgumentsError(
              message: 'Invalid arguments', errorCode: 5002),
          const PermissionDeniedError(
              message: 'Permission denied', errorCode: 4001),
          const UnknownError(message: 'Unknown error', errorCode: 1000),
        ];

        for (final error in errors) {
          final result = error.toString();
          expect(result, equals('${error.runtimeType}: ${error.message}'));
        }
      });
    });
  });
}
