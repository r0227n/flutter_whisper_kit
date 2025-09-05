import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/src/error_codes.dart';
import 'package:flutter_whisper_kit/src/whisper_kit_error.dart';

void main() {
  group('Error constants', () {
    test('initialization error codes should be in correct range', () {
      // Given & When & Then
      expect(ErrorCode.modelNotFound, greaterThanOrEqualTo(1000));
      expect(ErrorCode.modelNotFound, lessThanOrEqualTo(1999));

      expect(ErrorCode.invalidConfiguration, greaterThanOrEqualTo(1000));
      expect(ErrorCode.invalidConfiguration, lessThanOrEqualTo(1999));

      expect(ErrorCode.modelLoadingFailed, greaterThanOrEqualTo(1000));
      expect(ErrorCode.modelLoadingFailed, lessThanOrEqualTo(1999));
    });

    test('runtime error codes should be in correct range', () {
      // Given & When & Then
      expect(ErrorCode.transcriptionFailed, greaterThanOrEqualTo(2000));
      expect(ErrorCode.transcriptionFailed, lessThanOrEqualTo(2999));

      expect(ErrorCode.audioProcessingError, greaterThanOrEqualTo(2000));
      expect(ErrorCode.audioProcessingError, lessThanOrEqualTo(2999));

      expect(ErrorCode.languageDetectionFailed, greaterThanOrEqualTo(2000));
      expect(ErrorCode.languageDetectionFailed, lessThanOrEqualTo(2999));
    });

    test('network error codes should be in correct range', () {
      // Given & When & Then
      expect(ErrorCode.downloadFailed, greaterThanOrEqualTo(3000));
      expect(ErrorCode.downloadFailed, lessThanOrEqualTo(3999));

      expect(ErrorCode.networkTimeout, greaterThanOrEqualTo(3000));
      expect(ErrorCode.networkTimeout, lessThanOrEqualTo(3999));

      expect(ErrorCode.networkUnavailable, greaterThanOrEqualTo(3000));
      expect(ErrorCode.networkUnavailable, lessThanOrEqualTo(3999));
    });

    test('permission error codes should be in correct range', () {
      // Given & When & Then
      expect(ErrorCode.microphonePermissionDenied, greaterThanOrEqualTo(4000));
      expect(ErrorCode.microphonePermissionDenied, lessThanOrEqualTo(4999));

      expect(ErrorCode.fileAccessDenied, greaterThanOrEqualTo(4000));
      expect(ErrorCode.fileAccessDenied, lessThanOrEqualTo(4999));
    });

    test('validation error codes should be in correct range', () {
      // Given & When & Then
      expect(ErrorCode.invalidAudioFormat, greaterThanOrEqualTo(5000));
      expect(ErrorCode.invalidAudioFormat, lessThanOrEqualTo(5999));

      expect(ErrorCode.invalidParameters, greaterThanOrEqualTo(5000));
      expect(ErrorCode.invalidParameters, lessThanOrEqualTo(5999));
    });

    test('error codes should have descriptive messages', () {
      // Given & When & Then
      expect(
        ErrorCode.getDescription(ErrorCode.modelNotFound),
        contains('Model not found'),
      );

      expect(
        ErrorCode.getDescription(ErrorCode.transcriptionFailed),
        contains('Transcription failed'),
      );

      expect(
        ErrorCode.getDescription(ErrorCode.networkTimeout),
        contains('Network timeout'),
      );
    });

    test('error codes should map to correct error types', () {
      // Given & When
      final modelError = WhisperKitError.fromCode(
        ErrorCode.modelNotFound,
        'Custom message',
      );

      final transcriptionError = WhisperKitError.fromCode(
        ErrorCode.transcriptionFailed,
        'Custom message',
      );

      // Then
      expect(modelError, isA<WhisperKitError>());
      expect(modelError.code, ErrorCode.modelNotFound);

      expect(transcriptionError, isA<WhisperKitError>());
      expect(transcriptionError.code, ErrorCode.transcriptionFailed);
    });

    test('should provide category for error codes', () {
      // Given & When & Then
      expect(
        ErrorCategory.fromCode(ErrorCode.modelNotFound),
        ErrorCategory.initialization,
      );

      expect(
        ErrorCategory.fromCode(ErrorCode.transcriptionFailed),
        ErrorCategory.runtime,
      );

      expect(
        ErrorCategory.fromCode(ErrorCode.networkTimeout),
        ErrorCategory.network,
      );

      expect(
        ErrorCategory.fromCode(ErrorCode.microphonePermissionDenied),
        ErrorCategory.permission,
      );

      expect(
        ErrorCategory.fromCode(ErrorCode.invalidAudioFormat),
        ErrorCategory.validation,
      );
    });
  });
}
