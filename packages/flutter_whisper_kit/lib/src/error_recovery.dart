import 'dart:async';
import 'dart:math';

import 'package:flutter_whisper_kit/src/models.dart';
import 'package:flutter_whisper_kit/src/whisper_kit_error.dart';

/// Defines the type of recovery strategy
enum RecoveryType {
  /// Automatically retry with exponential backoff
  automatic,

  /// Let the user handle the error
  manual,

  /// Custom recovery logic
  custom,
}

/// Defines the action to take for recovery
enum RecoveryAction {
  /// Retry the operation
  retry,

  /// Use fallback options
  fallback,

  /// Fail immediately
  fail,
}

/// Log levels for error recovery
enum LogLevel {
  /// No logging
  none,

  /// Only errors
  error,

  /// Warnings and errors
  warning,

  /// Info, warnings, and errors
  info,

  /// All logs including debug
  debug,
}

/// Retry policy configuration
class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.jitterFactor = 0.1,
  });

  /// Maximum number of retry attempts
  final int maxAttempts;

  /// Initial delay before first retry
  final Duration initialDelay;

  /// Maximum delay between retries
  final Duration maxDelay;

  /// Multiplier for exponential backoff
  final double backoffMultiplier;

  /// Jitter factor (0.0 to 1.0) to randomize delays
  final double jitterFactor;

  /// Calculate delay for a given attempt number (0-based)
  Duration getDelayForAttempt(int attempt) {
    if (attempt < 0) return initialDelay;

    // Calculate exponential backoff
    final exponentialDelay =
        initialDelay.inMilliseconds * pow(backoffMultiplier, attempt);

    // Apply max delay cap
    final cappedDelay = exponentialDelay
        .clamp(
          initialDelay.inMilliseconds,
          maxDelay.inMilliseconds,
        )
        .toInt();

    // Add jitter
    final jitter =
        (cappedDelay * jitterFactor * (Random().nextDouble() * 2 - 1)).toInt();

    return Duration(milliseconds: cappedDelay + jitter);
  }

  /// Check if an error code should be retried
  bool shouldRetry(int errorCode) {
    return ErrorCode.isRecoverable(errorCode);
  }
}

/// Fallback options when primary operation fails
class FallbackOptions {
  const FallbackOptions({
    this.useOfflineModel = false,
    this.offlineModelVariant = 'tiny',
    this.degradeQuality = false,
    this.skipWordTimestamps = false,
    this.reduceConcurrency = false,
  });

  /// Use offline model if available
  final bool useOfflineModel;

  /// Offline model variant to use
  final String offlineModelVariant;

  /// Degrade quality for better performance
  final bool degradeQuality;

  /// Skip word timestamps to speed up processing
  final bool skipWordTimestamps;

  /// Reduce concurrent workers
  final bool reduceConcurrency;

  /// Apply fallback options to decoding options
  DecodingOptions applyToDecodingOptions(DecodingOptions original) {
    return DecodingOptions(
      task: original.task,
      temperature: original.temperature,
      detectLanguage: original.detectLanguage,
      verbose: original.verbose,
      sampleLength: degradeQuality ? 224 : original.sampleLength,
      language: original.language,
      chunkingStrategy: original.chunkingStrategy,
      wordTimestamps: skipWordTimestamps ? false : original.wordTimestamps,
      topK: degradeQuality ? 1 : original.topK,
      concurrentWorkerCount:
          reduceConcurrency ? 1 : original.concurrentWorkerCount,
      temperatureIncrementOnFallback: original.temperatureIncrementOnFallback,
      temperatureFallbackCount: original.temperatureFallbackCount,
      usePrefillPrompt: original.usePrefillPrompt,
      usePrefillCache: original.usePrefillCache,
      skipSpecialTokens: original.skipSpecialTokens,
      withoutTimestamps: original.withoutTimestamps,
      maxInitialTimestamp: original.maxInitialTimestamp,
      clipTimestamps: original.clipTimestamps,
      promptTokens: original.promptTokens,
      prefixTokens: original.prefixTokens,
      suppressBlank: original.suppressBlank,
      supressTokens: original.supressTokens,
      compressionRatioThreshold: original.compressionRatioThreshold,
      logProbThreshold: original.logProbThreshold,
      firstTokenLogProbThreshold: original.firstTokenLogProbThreshold,
      noSpeechThreshold: original.noSpeechThreshold,
    );
  }
}

/// Error recovery strategy configuration
class ErrorRecoveryStrategy {
  const ErrorRecoveryStrategy._({
    required this.type,
    required this.retryPolicy,
    this.fallbackOptions,
    this.onError,
  });

  /// Create automatic recovery strategy
  factory ErrorRecoveryStrategy.automatic({
    RetryPolicy? retryPolicy,
    FallbackOptions? fallbackOptions,
  }) {
    return ErrorRecoveryStrategy._(
      type: RecoveryType.automatic,
      retryPolicy: retryPolicy ?? const RetryPolicy(),
      fallbackOptions: fallbackOptions,
    );
  }

  /// Create manual recovery strategy (no automatic retry)
  factory ErrorRecoveryStrategy.manual() {
    return ErrorRecoveryStrategy._(
      type: RecoveryType.manual,
      retryPolicy: const RetryPolicy(maxAttempts: 0),
    );
  }

  /// Create custom recovery strategy
  factory ErrorRecoveryStrategy.custom({
    required Future<RecoveryAction> Function(WhisperKitError error) onError,
    RetryPolicy? retryPolicy,
    FallbackOptions? fallbackOptions,
  }) {
    return ErrorRecoveryStrategy._(
      type: RecoveryType.custom,
      retryPolicy: retryPolicy ?? const RetryPolicy(),
      fallbackOptions: fallbackOptions,
      onError: onError,
    );
  }

  /// Type of recovery strategy
  final RecoveryType type;

  /// Retry policy for automatic recovery
  final RetryPolicy retryPolicy;

  /// Fallback options
  final FallbackOptions? fallbackOptions;

  /// Custom error handler
  final Future<RecoveryAction> Function(WhisperKitError error)? onError;
}

/// Main configuration for WhisperKit with error recovery
class WhisperKitConfiguration {
  const WhisperKitConfiguration({
    required this.errorRecovery,
    required this.retryPolicy,
    required this.fallbackOptions,
    this.enableLogging = false,
    this.logLevel = LogLevel.error,
  });

  /// Create default configuration
  factory WhisperKitConfiguration.defaultConfig() {
    return WhisperKitConfiguration(
      errorRecovery: ErrorRecoveryStrategy.automatic(),
      retryPolicy: const RetryPolicy(),
      fallbackOptions: const FallbackOptions(),
    );
  }

  /// Create production-ready configuration
  factory WhisperKitConfiguration.production() {
    return WhisperKitConfiguration(
      errorRecovery: ErrorRecoveryStrategy.automatic(
        retryPolicy: const RetryPolicy(
          maxAttempts: 3,
          initialDelay: Duration(seconds: 1),
          maxDelay: Duration(seconds: 30),
          backoffMultiplier: 2.0,
          jitterFactor: 0.1,
        ),
        fallbackOptions: const FallbackOptions(
          useOfflineModel: true,
          offlineModelVariant: 'tiny',
          degradeQuality: true,
          skipWordTimestamps: true,
        ),
      ),
      retryPolicy: const RetryPolicy(maxAttempts: 3),
      fallbackOptions: const FallbackOptions(useOfflineModel: true),
      enableLogging: true,
      logLevel: LogLevel.warning,
    );
  }

  /// Error recovery strategy
  final ErrorRecoveryStrategy errorRecovery;

  /// Retry policy
  final RetryPolicy retryPolicy;

  /// Fallback options
  final FallbackOptions fallbackOptions;

  /// Enable logging
  final bool enableLogging;

  /// Log level
  final LogLevel logLevel;
}

/// Executes operations with error recovery
class RecoveryExecutor {
  RecoveryExecutor({
    required this.retryPolicy,
    this.fallbackOptions,
    this.logger,
  });
  final RetryPolicy retryPolicy;
  final FallbackOptions? fallbackOptions;
  final void Function(String message, LogLevel level)? logger;

  /// Execute an operation with retry logic
  Future<Result<T, WhisperKitError>> executeWithRetry<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    int attempt = 0;
    WhisperKitError? lastError;

    while (attempt < retryPolicy.maxAttempts) {
      try {
        _log(
            'Executing ${operationName ?? 'operation'} (attempt ${attempt + 1}/${retryPolicy.maxAttempts})',
            LogLevel.debug);

        final result = await operation();
        return Success(result);
      } on WhisperKitError catch (e) {
        lastError = e;

        _log('Error on attempt ${attempt + 1}: ${e.message} (code: ${e.code})',
            LogLevel.warning);

        // Check if error is retryable
        if (!retryPolicy.shouldRetry(e.code)) {
          _log('Error code ${e.code} is not retryable', LogLevel.info);
          return Failure(e);
        }

        // Check if we have more attempts
        if (attempt + 1 >= retryPolicy.maxAttempts) {
          _log('Max retry attempts reached', LogLevel.error);
          return Failure(e);
        }

        // Calculate and apply delay
        final delay = retryPolicy.getDelayForAttempt(attempt);
        _log('Waiting ${delay.inMilliseconds}ms before retry', LogLevel.debug);
        await Future.delayed(delay);

        attempt++;
      } catch (e) {
        // Handle non-WhisperKitError exceptions
        final error = TranscriptionFailedError(
          code: ErrorCode.transcriptionFailed,
          message: 'Unexpected error: $e',
        );
        return Failure(error);
      }
    }

    // Should not reach here, but return last error if we do
    return Failure(lastError ??
        TranscriptionFailedError(
          code: ErrorCode.transcriptionFailed,
          message: 'Operation failed after retries',
        ));
  }

  void _log(String message, LogLevel level) {
    logger?.call('[RecoveryExecutor] $message', level);
  }
}
