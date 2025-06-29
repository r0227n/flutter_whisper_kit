import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/src/error_codes.dart';
import 'package:flutter_whisper_kit/src/whisper_kit_error.dart';

void main() {
  group('ErrorCode', () {
    group('getCategory', () {
      test('should categorize initialization errors correctly', () {
        expect(ErrorCategory.fromCode(ErrorCode.modelNotFound),
            equals(ErrorCategory.initialization));
        expect(ErrorCategory.fromCode(ErrorCode.invalidConfiguration),
            equals(ErrorCategory.initialization));
        expect(ErrorCategory.fromCode(ErrorCode.modelLoadingFailed),
            equals(ErrorCategory.initialization));
        expect(
            ErrorCategory.fromCode(1999), equals(ErrorCategory.initialization));
      });

      test('should categorize runtime errors correctly', () {
        expect(ErrorCategory.fromCode(ErrorCode.transcriptionFailed),
            equals(ErrorCategory.runtime));
        expect(ErrorCategory.fromCode(ErrorCode.audioProcessingError),
            equals(ErrorCategory.runtime));
        expect(ErrorCategory.fromCode(2999), equals(ErrorCategory.runtime));
      });

      test('should categorize network errors correctly', () {
        expect(ErrorCategory.fromCode(ErrorCode.downloadFailed),
            equals(ErrorCategory.network));
        expect(ErrorCategory.fromCode(ErrorCode.networkTimeout),
            equals(ErrorCategory.network));
        expect(ErrorCategory.fromCode(3999), equals(ErrorCategory.network));
      });

      test('should categorize permission errors correctly', () {
        expect(ErrorCategory.fromCode(ErrorCode.microphonePermissionDenied),
            equals(ErrorCategory.permission));
        expect(ErrorCategory.fromCode(ErrorCode.fileAccessDenied),
            equals(ErrorCategory.permission));
        expect(ErrorCategory.fromCode(4999), equals(ErrorCategory.permission));
      });

      test('should categorize validation errors correctly', () {
        expect(ErrorCategory.fromCode(ErrorCode.invalidAudioFormat),
            equals(ErrorCategory.validation));
        expect(ErrorCategory.fromCode(ErrorCode.invalidParameters),
            equals(ErrorCategory.validation));
        expect(ErrorCategory.fromCode(5999), equals(ErrorCategory.validation));
      });

      test('should default to runtime category for unknown codes', () {
        expect(ErrorCategory.fromCode(999), equals(ErrorCategory.runtime));
        expect(ErrorCategory.fromCode(6000), equals(ErrorCategory.runtime));
        expect(ErrorCategory.fromCode(-1), equals(ErrorCategory.runtime));
      });
    });

    group('getDescription', () {
      test('should return correct descriptions for initialization errors', () {
        expect(ErrorCode.getDescription(ErrorCode.modelNotFound),
            equals('Model not found at specified path'));
        expect(ErrorCode.getDescription(ErrorCode.insufficientMemory),
            equals('Insufficient memory to load model'));
      });

      test('should return correct descriptions for runtime errors', () {
        expect(ErrorCode.getDescription(ErrorCode.transcriptionFailed),
            equals('Transcription failed'));
        expect(ErrorCode.getDescription(ErrorCode.unsupportedAudioFormat),
            equals('Audio format not supported'));
      });

      test('should return correct descriptions for network errors', () {
        expect(ErrorCode.getDescription(ErrorCode.downloadFailed),
            equals('Download failed'));
        expect(ErrorCode.getDescription(ErrorCode.checksumMismatch),
            equals('File checksum verification failed'));
      });

      test('should return correct descriptions for permission errors', () {
        expect(ErrorCode.getDescription(ErrorCode.microphonePermissionDenied),
            equals('Microphone permission denied'));
        expect(ErrorCode.getDescription(ErrorCode.storagePermissionDenied),
            equals('Storage permission denied'));
      });

      test('should return correct descriptions for validation errors', () {
        expect(ErrorCode.getDescription(ErrorCode.audioTooShort),
            equals('Audio file too short'));
        expect(ErrorCode.getDescription(ErrorCode.audioTooLong),
            equals('Audio file too long'));
      });

      test('should return unknown error for invalid codes', () {
        expect(ErrorCode.getDescription(9999), equals('Unknown error'));
        expect(ErrorCode.getDescription(-1), equals('Unknown error'));
      });
    });

    group('isRecoverable', () {
      test('should identify recoverable network errors', () {
        expect(ErrorCode.isRecoverable(ErrorCode.networkTimeout), isTrue);
        expect(ErrorCode.isRecoverable(ErrorCode.networkUnavailable), isTrue);
        expect(ErrorCode.isRecoverable(ErrorCode.downloadFailed), isTrue);
      });

      test('should identify recoverable runtime errors', () {
        expect(ErrorCode.isRecoverable(ErrorCode.transcriptionFailed), isTrue);
        expect(ErrorCode.isRecoverable(ErrorCode.audioProcessingError), isTrue);
      });

      test('should identify non-recoverable errors', () {
        expect(ErrorCode.isRecoverable(ErrorCode.modelNotFound), isFalse);
        expect(
            ErrorCode.isRecoverable(ErrorCode.invalidConfiguration), isFalse);
        expect(ErrorCode.isRecoverable(ErrorCode.microphonePermissionDenied),
            isFalse);
        expect(ErrorCode.isRecoverable(ErrorCode.invalidAudioFormat), isFalse);
      });
    });

    group('getSuggestedAction', () {
      test('should return appropriate actions for specific errors', () {
        expect(ErrorCode.getSuggestedAction(ErrorCode.modelNotFound),
            equals('Check model path or download the model'));

        expect(ErrorCode.getSuggestedAction(ErrorCode.networkTimeout),
            equals('Check network connection and retry'));
        expect(ErrorCode.getSuggestedAction(ErrorCode.networkUnavailable),
            equals('Check network connection and retry'));

        expect(
            ErrorCode.getSuggestedAction(ErrorCode.microphonePermissionDenied),
            equals('Grant microphone permission in settings'));

        expect(ErrorCode.getSuggestedAction(ErrorCode.insufficientMemory),
            equals('Free up memory or use a smaller model'));

        expect(ErrorCode.getSuggestedAction(ErrorCode.invalidAudioFormat),
            equals('Convert audio to supported format (WAV, MP3, M4A)'));
      });

      test('should return default action for unspecified errors', () {
        expect(ErrorCode.getSuggestedAction(ErrorCode.transcriptionFailed),
            equals('Please check the error details and try again'));
        expect(ErrorCode.getSuggestedAction(9999),
            equals('Please check the error details and try again'));
      });
    });

      test('should create error with custom message', () {
        final customMessage = 'Custom error message';
        final error =
            WhisperKitError.fromCode(ErrorCode.transcriptionFailed, customMessage);

        expect(error, isA<WhisperKitError>());
        expect(error.code, equals(ErrorCode.transcriptionFailed));
        expect(error.message, equals(customMessage));
      });

      test('should create error with unknown code', () {
        final error = WhisperKitError.fromCode(9999);

        expect(error, isA<WhisperKitError>());
        expect(error.code, equals(9999));
        expect(error.message, equals('Unknown error'));
      });
    });
  });
}
