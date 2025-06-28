import 'whisper_kit_error.dart';

/// Categories of errors for better organization and handling
enum ErrorCategory {
  /// Initialization errors (1000-1999)
  initialization,
  
  /// Runtime errors (2000-2999)
  runtime,
  
  /// Network errors (3000-3999)
  network,
  
  /// Permission errors (4000-4999)
  permission,
  
  /// Validation errors (5000-5999)
  validation;

  const ErrorCategory();

  /// Gets the error category for a given error code
  factory ErrorCategory.fromCode(int code) {
    return switch (code) {
      >= 1000 && <= 1999 => ErrorCategory.initialization,
      >= 2000 && <= 2999 => ErrorCategory.runtime,
      >= 3000 && <= 3999 => ErrorCategory.network,
      >= 4000 && <= 4999 => ErrorCategory.permission,
      >= 5000 && <= 5999 => ErrorCategory.validation,
      _ => ErrorCategory.runtime, // Default to runtime
    };
  }
}

/// Standardized error codes for WhisperKit.
/// 
/// This class provides centralized error code constants following
/// a clear categorization scheme:
/// - 1000-1999: Initialization errors
/// - 2000-2999: Runtime errors
/// - 3000-3999: Network errors
/// - 4000-4999: Permission errors
/// - 5000-5999: Validation errors
abstract class ErrorCode {
  // Initialization errors (1000-1999)
  
  /// Model file not found at the specified path
  static const int modelNotFound = 1001;
  
  /// Invalid configuration provided
  static const int invalidConfiguration = 1002;
  
  /// Model loading failed for generic reasons
  static const int modelLoadingFailed = 1003;
  
  /// Model version incompatible
  static const int incompatibleModelVersion = 1004;
  
  /// Insufficient memory to load model
  static const int insufficientMemory = 1005;
  
  // Runtime errors (2000-2999)
  
  /// Transcription process failed
  static const int transcriptionFailed = 2001;
  
  /// Audio processing error occurred
  static const int audioProcessingError = 2002;
  
  /// Language detection failed
  static const int languageDetectionFailed = 2003;
  
  /// Real-time transcription error
  static const int realtimeTranscriptionError = 2004;
  
  /// Audio format not supported
  static const int unsupportedAudioFormat = 2005;
  
  // Network errors (3000-3999)
  
  /// Model download failed
  static const int downloadFailed = 3001;
  
  /// Network request timeout
  static const int networkTimeout = 3002;
  
  /// Network unavailable
  static const int networkUnavailable = 3003;
  
  /// Download cancelled by user
  static const int downloadCancelled = 3004;
  
  /// Checksum verification failed
  static const int checksumMismatch = 3005;
  
  // Permission errors (4000-4999)
  
  /// Microphone permission denied
  static const int microphonePermissionDenied = 4001;
  
  /// File access permission denied
  static const int fileAccessDenied = 4002;
  
  /// Storage permission denied
  static const int storagePermissionDenied = 4003;
  
  // Validation errors (5000-5999)
  
  /// Invalid audio format provided
  static const int invalidAudioFormat = 5001;
  
  /// Invalid parameters provided
  static const int invalidParameters = 5002;
  
  /// Invalid file path
  static const int invalidFilePath = 5003;
  
  /// Audio file too short
  static const int audioTooShort = 5004;
  
  /// Audio file too long
  static const int audioTooLong = 5005;
  
  /// Gets a human-readable description for an error code
  static String getDescription(int code) {
    return switch (code) {
      // Initialization errors
      modelNotFound => 'Model not found at specified path',
      invalidConfiguration => 'Invalid configuration provided',
      modelLoadingFailed => 'Failed to load model',
      incompatibleModelVersion => 'Model version is incompatible',
      insufficientMemory => 'Insufficient memory to load model',
      
      // Runtime errors
      transcriptionFailed => 'Transcription failed',
      audioProcessingError => 'Error processing audio',
      languageDetectionFailed => 'Language detection failed',
      realtimeTranscriptionError => 'Real-time transcription error',
      unsupportedAudioFormat => 'Audio format not supported',
      
      // Network errors
      downloadFailed => 'Download failed',
      networkTimeout => 'Network timeout',
      networkUnavailable => 'Network unavailable',
      downloadCancelled => 'Download cancelled',
      checksumMismatch => 'File checksum verification failed',
      
      // Permission errors
      microphonePermissionDenied => 'Microphone permission denied',
      fileAccessDenied => 'File access denied',
      storagePermissionDenied => 'Storage permission denied',
      
      // Validation errors
      invalidAudioFormat => 'Invalid audio format',
      invalidParameters => 'Invalid parameters',
      invalidFilePath => 'Invalid file path',
      audioTooShort => 'Audio file too short',
      audioTooLong => 'Audio file too long',
      
      _ => 'Unknown error',
    };
  }
  
  /// Creates a WhisperKitError with the specified code and optional custom message
  static WhisperKitError createError(int code, [String? customMessage]) {
    final message = customMessage ?? getDescription(code);
    return WhisperKitError(code: code, message: message);
  }
  
  /// Checks if an error code represents a recoverable error
  static bool isRecoverable(int code) {
    return switch (code) {
      // Network errors are often recoverable with retry
      networkTimeout => true,
      networkUnavailable => true,
      downloadFailed => true,
      
      // Some runtime errors might be recoverable
      transcriptionFailed => true,
      audioProcessingError => true,
      
      // Most other errors are not recoverable
      _ => false,
    };
  }
  
  /// Gets suggested action for an error code
  static String getSuggestedAction(int code) {
    return switch (code) {
      modelNotFound => 'Check model path or download the model',
      networkTimeout => 'Check network connection and retry',
      networkUnavailable => 'Check network connection and retry',
      microphonePermissionDenied => 'Grant microphone permission in settings',
      insufficientMemory => 'Free up memory or use a smaller model',
      invalidAudioFormat => 'Convert audio to supported format (WAV, MP3, M4A)',
      _ => 'Please check the error details and try again',
    };
  }
}