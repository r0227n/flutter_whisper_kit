import 'package:flutter/services.dart';

/// A generic WhisperKit error with code
class WhisperKitError implements Exception {
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

  @override
  String toString() => 'WhisperKitError($code): $message';
}

/// A sealed class hierarchy for WhisperKit errors
sealed class WhisperKitErrorType implements Exception {
  /// Creates a new WhisperKitErrorType
  const WhisperKitErrorType(
      {required this.message, this.details, required this.errorCode});

  /// A human-readable error message
  final String message;

  /// Additional error details
  final dynamic details;

  /// The original error code
  final int errorCode;

  /// Creates a WhisperKitErrorType from a PlatformException
  factory WhisperKitErrorType.fromPlatformException(PlatformException e) {
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
              errorCode: errorCode,
            ),

          // Transcription and Processing (2000-2999)
          >= 2000 && <= 2999 => TranscriptionFailedError(
              message: errorMessage,
              details: details,
              errorCode: errorCode,
            ),

          // Recording and Audio Capture (3000-3999)
          >= 3000 && <= 3999 => RecordingFailedError(
              message: errorMessage,
              details: details,
              errorCode: errorCode,
            ),

          // File System and Permissions (4000-4999)
          >= 4000 && <= 4999 => PermissionDeniedError(
              message: errorMessage,
              details: details,
              errorCode: errorCode,
            ),

          // Configuration and Parameters (5000-5999)
          >= 5000 && <= 5999 => InvalidArgumentsError(
              message: errorMessage,
              details: details,
              errorCode: errorCode,
            ),

          // Default case for unhandled numeric error codes
          _ => UnknownError(
              message: errorMessage, details: details, errorCode: errorCode),
        };
      }
    }

    return UnknownError(message: message, details: details, errorCode: 1000);
  }

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

/// Factory for creating WhisperKitError from PlatformException
class WhisperKitErrorFactory {
  /// Creates a WhisperKitError from a PlatformException
  static WhisperKitError fromPlatformException(PlatformException e) {
    final code = e.code;
    final message = e.message ?? 'Unknown error';
    final details = e.details;

    // Parse NSError format
    final nsErrorRegex = RegExp(r'Domain=(\w+)\s+Code=(\d+)\s+"([^"]+)"');
    final match = nsErrorRegex.firstMatch(code);
    if (match != null) {
      final errorCode = int.tryParse(match.group(2) ?? '') ?? 0;
      final errorMessage = match.group(3) ?? message;

      return WhisperKitError(
        code: errorCode,
        message: errorMessage,
        details: details,
      );
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

    return WhisperKitError(
      code: errorCode,
      message: message,
      details: details,
    );
  }
}

/// Error when model loading fails
class ModelLoadingFailedError extends WhisperKitErrorType {
  /// Creates a new ModelLoadingFailedError
  const ModelLoadingFailedError(
      {required super.message, super.details, required super.errorCode});
}

/// Error when transcription fails
class TranscriptionFailedError extends WhisperKitErrorType {
  /// Creates a new TranscriptionFailedError
  const TranscriptionFailedError(
      {required super.message, super.details, required super.errorCode});
}

/// Error when recording fails
class RecordingFailedError extends WhisperKitErrorType {
  /// Creates a new RecordingFailedError
  const RecordingFailedError(
      {required super.message, super.details, required super.errorCode});
}

/// Error when arguments are invalid
class InvalidArgumentsError extends WhisperKitErrorType {
  /// Creates a new InvalidArgumentsError
  const InvalidArgumentsError(
      {required super.message, super.details, required super.errorCode});
}

/// Error when permission is denied
class PermissionDeniedError extends WhisperKitErrorType {
  /// Creates a new PermissionDeniedError
  const PermissionDeniedError(
      {required super.message, super.details, required super.errorCode});
}

/// Error when the cause is unknown
class UnknownError extends WhisperKitErrorType {
  /// Creates a new UnknownError
  const UnknownError(
      {required super.message, super.details, required super.errorCode});
}
