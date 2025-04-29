import 'package:flutter/services.dart';

/// Error codes for WhisperKit operations
enum WhisperKitErrorCode {
  /// Model loading failed
  modelLoadingFailed,

  /// Transcription failed
  transcriptionFailed,

  /// Recording failed
  recordingFailed,

  /// Invalid arguments
  invalidArguments,

  /// Permission denied
  permissionDenied,

  /// Unknown error
  unknown,
}

/// A standardized error class for WhisperKit operations
class WhisperKitError implements Exception {
  /// Creates a new WhisperKitError
  WhisperKitError({
    required this.code,
    required this.message,
    this.details,
  });

  /// Creates a WhisperKitError from a PlatformException
  factory WhisperKitError.fromPlatformException(PlatformException e) {
    final code = _mapErrorCode(e.code);
    return WhisperKitError(
      code: code,
      message: e.message ?? 'Unknown error',
      details: e.details,
    );
  }

  /// The error code
  final WhisperKitErrorCode code;

  /// A human-readable error message
  final String message;

  /// Additional error details
  final dynamic details;

  /// Maps a platform exception code to a WhisperKitErrorCode
  static WhisperKitErrorCode _mapErrorCode(String code) {
    switch (code) {
      case 'model_loading_failed':
        return WhisperKitErrorCode.modelLoadingFailed;
      case 'transcription_failed':
        return WhisperKitErrorCode.transcriptionFailed;
      case 'recording_failed':
        return WhisperKitErrorCode.recordingFailed;
      case 'invalid_arguments':
        return WhisperKitErrorCode.invalidArguments;
      case 'permission_denied':
        return WhisperKitErrorCode.permissionDenied;
      default:
        return WhisperKitErrorCode.unknown;
    }
  }

  @override
  String toString() => 'WhisperKitError($code): $message';
}
