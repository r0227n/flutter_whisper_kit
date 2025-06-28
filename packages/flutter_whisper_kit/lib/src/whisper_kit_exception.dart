/// Base exception class for WhisperKit that can be extended
abstract class WhisperKitException implements Exception {
  /// Creates a new WhisperKitException
  const WhisperKitException();
}

/// A generic WhisperKit exception with code
class WhisperKitError extends WhisperKitException {
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
