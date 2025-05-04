import 'package:flutter/services.dart';

/// A sealed class hierarchy for WhisperKit errors
sealed class WhisperKitError implements Exception {
  /// Creates a new WhisperKitError
  const WhisperKitError({required this.message, this.details});

  /// A human-readable error message
  final String message;

  /// Additional error details
  final dynamic details;

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
            message: errorMessage,
            details: details,
          ),

          // Transcription and Processing (2000-2999)
          >= 2000 && <= 2999 => TranscriptionFailedError(
            message: errorMessage,
            details: details,
          ),

          // Recording and Audio Capture (3000-3999)
          >= 3000 && <= 3999 => RecordingFailedError(
            message: errorMessage,
            details: details,
          ),

          // File System and Permissions (4000-4999)
          >= 4000 && <= 4999 => PermissionDeniedError(
            message: errorMessage,
            details: details,
          ),

          // Configuration and Parameters (5000-5999)
          >= 5000 && <= 5999 => InvalidArgumentsError(
            message: errorMessage,
            details: details,
          ),

          // Default case for unhandled numeric error codes
          _ => UnknownError(message: errorMessage, details: details),
        };
      }
    }

    return UnknownError(message: message, details: details);
  }

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

/// Error when model loading fails
class ModelLoadingFailedError extends WhisperKitError {
  /// Creates a new ModelLoadingFailedError
  const ModelLoadingFailedError({required super.message, super.details});
}

/// Error when transcription fails
class TranscriptionFailedError extends WhisperKitError {
  /// Creates a new TranscriptionFailedError
  const TranscriptionFailedError({required super.message, super.details});
}

/// Error when recording fails
class RecordingFailedError extends WhisperKitError {
  /// Creates a new RecordingFailedError
  const RecordingFailedError({required super.message, super.details});
}

/// Error when arguments are invalid
class InvalidArgumentsError extends WhisperKitError {
  /// Creates a new InvalidArgumentsError
  const InvalidArgumentsError({required super.message, super.details});
}

/// Error when permission is denied
class PermissionDeniedError extends WhisperKitError {
  /// Creates a new PermissionDeniedError
  const PermissionDeniedError({required super.message, super.details});
}

/// Error when the cause is unknown
class UnknownError extends WhisperKitError {
  /// Creates a new UnknownError
  const UnknownError({required super.message, super.details});
}
