import 'package:flutter/services.dart';
import 'package:flutter_whisper_kit/src/error_codes.dart' show ErrorCode;

/// A sealed class hierarchy for WhisperKit errors
sealed class WhisperKitError implements Exception {
  /// Creates a new WhisperKitError
  const WhisperKitError({
    required this.code,
    required this.message,
    this.details,
  });

  /// The error code
  final int code;

  /// A human-readable error message
  final String message;

  /// Additional error details
  final dynamic details;

  /// Creates a WhisperKitError with the specified code and optional custom message
  factory WhisperKitError.fromCode(int code, [String? customMessage]) {
    // Import ErrorCode functionality here
    final message = customMessage ?? ErrorCode.getDescription(code);

    // Create appropriate error type based on code range
    return switch (code) {
      >= 1000 && <= 1999 =>
        ModelLoadingFailedError(code: code, message: message),
      >= 2000 && <= 2999 =>
        TranscriptionFailedError(code: code, message: message),
      >= 3000 && <= 3999 => RecordingFailedError(code: code, message: message),
      >= 4000 && <= 4999 => PermissionDeniedError(code: code, message: message),
      >= 5000 && <= 5999 => InvalidArgumentsError(code: code, message: message),
      _ => UnknownError(code: code, message: message),
    };
  }

  /// Creates a WhisperKitError from a PlatformException
  factory WhisperKitError.fromPlatformException(PlatformException e) {
    final code = e.code;
    final message = e.message ?? 'Unknown error';
    final details = e.details;

    // Parse NSError format
    final nsErrorRegex = RegExp(r'Domain=(\w+)\s+Code=(\d+)\s+"([^"]+)"');
    final match = nsErrorRegex.firstMatch(code);
    if (match != null) {
      final errorDomain = match.group(1);
      final errorCode = int.tryParse(match.group(2) ?? '') ?? 0;
      final errorMessage = match.group(3) ?? message;

      if (errorDomain == 'WhisperKitError') {
        return switch (errorCode) {
          // Handle all other model initialization errors (1000-1999)
          >= 1000 && <= 1999 => ModelLoadingFailedError(
              code: errorCode,
              message: errorMessage,
              details: details,
            ),

          // Transcription and Processing (2000-2999)
          >= 2000 && <= 2999 => TranscriptionFailedError(
              code: errorCode,
              message: errorMessage,
              details: details,
            ),

          // Recording and Audio Capture (3000-3999)
          >= 3000 && <= 3999 => RecordingFailedError(
              code: errorCode,
              message: errorMessage,
              details: details,
            ),

          // File System and Permissions (4000-4999)
          >= 4000 && <= 4999 => PermissionDeniedError(
              code: errorCode,
              message: errorMessage,
              details: details,
            ),

          // Configuration and Parameters (5000-5999)
          >= 5000 && <= 5999 => InvalidArgumentsError(
              code: errorCode,
              message: errorMessage,
              details: details,
            ),

          // Default case for unhandled numeric error codes
          _ => UnknownError(
              code: errorCode,
              message: errorMessage,
              details: details,
            ),
        };
      }
    }

    // Default error code based on message content
    int errorCode = 1000; // Default to general initialization error
    if (message.toLowerCase().contains('transcription')) {
      errorCode = 2001;
    } else if (message.toLowerCase().contains('permission')) {
      errorCode = 4001;
    } else if (message.toLowerCase().contains('network')) {
      errorCode = 3001;
    }

    return UnknownError(
      code: errorCode,
      message: message,
      details: details,
    );
  }

  @override
  String toString() => '${runtimeType.toString()}($code): $message';
}

/// Error when model loading fails
final class ModelLoadingFailedError extends WhisperKitError {
  /// Creates a new ModelLoadingFailedError
  const ModelLoadingFailedError({
    required super.code,
    required super.message,
    super.details,
  });
}

/// Error when transcription fails
final class TranscriptionFailedError extends WhisperKitError {
  /// Creates a new TranscriptionFailedError
  const TranscriptionFailedError({
    required super.code,
    required super.message,
    super.details,
  });
}

/// Error when recording fails
final class RecordingFailedError extends WhisperKitError {
  /// Creates a new RecordingFailedError
  const RecordingFailedError({
    required super.code,
    required super.message,
    super.details,
  });
}

/// Error when arguments are invalid
final class InvalidArgumentsError extends WhisperKitError {
  /// Creates a new InvalidArgumentsError
  const InvalidArgumentsError({
    required super.code,
    required super.message,
    super.details,
  });
}

/// Error when permission is denied
final class PermissionDeniedError extends WhisperKitError {
  /// Creates a new PermissionDeniedError
  const PermissionDeniedError({
    required super.code,
    required super.message,
    super.details,
  });
}

/// Error when the cause is unknown
final class UnknownError extends WhisperKitError {
  /// Creates a new UnknownError
  const UnknownError({
    required super.code,
    required super.message,
    super.details,
  });
}
