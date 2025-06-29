import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/src/error_recovery.dart';
import 'package:flutter_whisper_kit/src/whisper_kit_error.dart';
import 'package:flutter_whisper_kit/src/models.dart';

void main() {
  group('RetryPolicy', () {
    test('should have correct default values', () {
      const policy = RetryPolicy();

      expect(policy.maxAttempts, equals(3));
      expect(policy.initialDelay, equals(const Duration(seconds: 1)));
      expect(policy.maxDelay, equals(const Duration(seconds: 30)));
      expect(policy.backoffMultiplier, equals(2.0));
      expect(policy.jitterFactor, equals(0.1));
    });

    group('getDelayForAttempt', () {
      test('should return initial delay for negative attempt', () {
        const policy = RetryPolicy(initialDelay: Duration(milliseconds: 100));
        expect(policy.getDelayForAttempt(-1),
            equals(const Duration(milliseconds: 100)));
      });

      test('should calculate exponential backoff correctly', () {
        const policy = RetryPolicy(
          initialDelay: Duration(milliseconds: 100),
          backoffMultiplier: 2.0,
          jitterFactor: 0.0, // No jitter for predictable tests
        );

        expect(policy.getDelayForAttempt(0).inMilliseconds, equals(100));
        expect(policy.getDelayForAttempt(1).inMilliseconds, equals(200));
        expect(policy.getDelayForAttempt(2).inMilliseconds, equals(400));
        expect(policy.getDelayForAttempt(3).inMilliseconds, equals(800));
      });

      test('should cap delay at maxDelay', () {
        const policy = RetryPolicy(
          initialDelay: Duration(seconds: 1),
          maxDelay: Duration(seconds: 5),
          backoffMultiplier: 3.0,
          jitterFactor: 0.0,
        );

        // Attempt 3 would be 27 seconds without cap
        expect(policy.getDelayForAttempt(3).inSeconds, equals(5));
        expect(policy.getDelayForAttempt(10).inSeconds, equals(5));
      });

      test('should apply jitter within expected range', () {
        const policy = RetryPolicy(
          initialDelay: Duration(seconds: 1),
          jitterFactor: 0.2,
        );

        // Test multiple times to ensure jitter is applied
        final delays = List.generate(10, (_) => policy.getDelayForAttempt(1));

        // All delays should be within 20% of base delay (1600-2400ms for attempt 1)
        for (final delay in delays) {
          expect(delay.inMilliseconds, greaterThanOrEqualTo(1600));
          expect(delay.inMilliseconds, lessThanOrEqualTo(2400));
        }

        // Delays should vary (not all the same)
        expect(delays.toSet().length, greaterThan(1));
      });
    });

    group('shouldRetry', () {
      test('should identify retryable error codes', () {
        const policy = RetryPolicy();

        // Network errors should be retryable
        expect(policy.shouldRetry(ErrorCode.networkTimeout), isTrue);
        expect(policy.shouldRetry(ErrorCode.networkUnavailable), isTrue);
        expect(policy.shouldRetry(ErrorCode.downloadFailed), isTrue);

        // Some runtime errors should be retryable
        expect(policy.shouldRetry(ErrorCode.transcriptionFailed), isTrue);
        expect(policy.shouldRetry(ErrorCode.audioProcessingError), isTrue);
      });

      test('should identify non-retryable error codes', () {
        const policy = RetryPolicy();

        // Configuration errors should not be retryable
        expect(policy.shouldRetry(ErrorCode.modelNotFound), isFalse);
        expect(policy.shouldRetry(ErrorCode.invalidConfiguration), isFalse);

        // Permission errors should not be retryable
        expect(
            policy.shouldRetry(ErrorCode.microphonePermissionDenied), isFalse);

        // Validation errors should not be retryable
        expect(policy.shouldRetry(ErrorCode.invalidAudioFormat), isFalse);
      });
    });
  });

  group('FallbackOptions', () {
    test('should have correct default values', () {
      const options = FallbackOptions();

      expect(options.useOfflineModel, isFalse);
      expect(options.offlineModelVariant, equals('tiny'));
      expect(options.degradeQuality, isFalse);
      expect(options.skipWordTimestamps, isFalse);
      expect(options.reduceConcurrency, isFalse);
    });

    group('applyToDecodingOptions', () {
      late DecodingOptions originalOptions;

      setUp(() {
        originalOptions = const DecodingOptions(
          task: DecodingTask.transcribe,
          language: 'en',
          temperature: 0.5,
          detectLanguage: true,
          verbose: true,
          wordTimestamps: true,
          topK: 5,
          sampleLength: 448,
          concurrentWorkerCount: 4,
          chunkingStrategy: ChunkingStrategy.vad,
        );
      });

      test('should preserve original options when no fallbacks applied', () {
        const fallback = FallbackOptions();
        final result = fallback.applyToDecodingOptions(originalOptions);

        expect(result.task, equals(originalOptions.task));
        expect(result.language, equals(originalOptions.language));
        expect(result.temperature, equals(originalOptions.temperature));
        expect(result.detectLanguage, equals(originalOptions.detectLanguage));
        expect(result.verbose, equals(originalOptions.verbose));
        expect(result.wordTimestamps, equals(originalOptions.wordTimestamps));
        expect(result.topK, equals(originalOptions.topK));
        expect(result.sampleLength, equals(originalOptions.sampleLength));
        expect(result.concurrentWorkerCount,
            equals(originalOptions.concurrentWorkerCount));
        expect(
            result.chunkingStrategy, equals(originalOptions.chunkingStrategy));
      });

      test('should skip word timestamps when fallback enabled', () {
        const fallback = FallbackOptions(skipWordTimestamps: true);
        final result = fallback.applyToDecodingOptions(originalOptions);

        expect(result.wordTimestamps, isFalse);
        // Other options should be preserved
        expect(result.task, equals(originalOptions.task));
        expect(result.language, equals(originalOptions.language));
      });

      test('should degrade quality when fallback enabled', () {
        const fallback = FallbackOptions(degradeQuality: true);
        final result = fallback.applyToDecodingOptions(originalOptions);

        expect(result.topK, equals(1));
        expect(result.sampleLength, equals(224));
        // Other options should be preserved
        expect(result.wordTimestamps, equals(originalOptions.wordTimestamps));
      });

      test('should reduce concurrency when fallback enabled', () {
        const fallback = FallbackOptions(reduceConcurrency: true);
        final result = fallback.applyToDecodingOptions(originalOptions);

        expect(result.concurrentWorkerCount, equals(1));
        // Other options should be preserved
        expect(result.topK, equals(originalOptions.topK));
      });

      test('should apply multiple fallbacks correctly', () {
        const fallback = FallbackOptions(
          skipWordTimestamps: true,
          degradeQuality: true,
          reduceConcurrency: true,
        );
        final result = fallback.applyToDecodingOptions(originalOptions);

        expect(result.wordTimestamps, isFalse);
        expect(result.topK, equals(1));
        expect(result.sampleLength, equals(224));
        expect(result.concurrentWorkerCount, equals(1));
        // Unaffected options should be preserved
        expect(result.task, equals(originalOptions.task));
        expect(result.language, equals(originalOptions.language));
        expect(result.temperature, equals(originalOptions.temperature));
      });
    });
  });

  group('ErrorRecoveryStrategy', () {
    test('automatic strategy should have correct configuration', () {
      final strategy = ErrorRecoveryStrategy.automatic();

      expect(strategy.type, equals(RecoveryType.automatic));
      expect(strategy.retryPolicy.maxAttempts, equals(3));
      expect(strategy.fallbackOptions, isNull);
      expect(strategy.onError, isNull);
    });

    test('automatic strategy with custom options', () {
      const customRetry = RetryPolicy(maxAttempts: 5);
      const customFallback = FallbackOptions(degradeQuality: true);

      final strategy = ErrorRecoveryStrategy.automatic(
        retryPolicy: customRetry,
        fallbackOptions: customFallback,
      );

      expect(strategy.type, equals(RecoveryType.automatic));
      expect(strategy.retryPolicy.maxAttempts, equals(5));
      expect(strategy.fallbackOptions?.degradeQuality, isTrue);
    });

    test('manual strategy should disable retries', () {
      final strategy = ErrorRecoveryStrategy.manual();

      expect(strategy.type, equals(RecoveryType.manual));
      expect(strategy.retryPolicy.maxAttempts, equals(0));
      expect(strategy.fallbackOptions, isNull);
      expect(strategy.onError, isNull);
    });

    test('custom strategy should include error handler', () {
      bool handlerCalled = false;

      final strategy = ErrorRecoveryStrategy.custom(
        onError: (error) async {
          handlerCalled = true;
          return RecoveryAction.retry;
        },
      );

      expect(strategy.type, equals(RecoveryType.custom));
      expect(strategy.retryPolicy.maxAttempts, equals(3));
      expect(strategy.onError, isNotNull);

      // Test the handler
      strategy.onError!(UnknownError(code: 1, message: 'test'));
      expect(handlerCalled, isTrue);
    });
  });

  group('WhisperKitConfiguration', () {
    test('default configuration should have sensible defaults', () {
      final config = WhisperKitConfiguration.defaultConfig();

      expect(config.errorRecovery.type, equals(RecoveryType.automatic));
      expect(config.retryPolicy.maxAttempts, equals(3));
      expect(config.enableLogging, isFalse);
      expect(config.logLevel, equals(LogLevel.error));
    });

    test('production configuration should have robust settings', () {
      final config = WhisperKitConfiguration.production();

      expect(config.errorRecovery.type, equals(RecoveryType.automatic));
      expect(config.errorRecovery.retryPolicy.maxAttempts, equals(3));
      expect(config.errorRecovery.fallbackOptions?.useOfflineModel, isTrue);
      expect(config.errorRecovery.fallbackOptions?.degradeQuality, isTrue);
      expect(config.errorRecovery.fallbackOptions?.skipWordTimestamps, isTrue);
      expect(config.enableLogging, isTrue);
      expect(config.logLevel, equals(LogLevel.warning));
    });
  });

  group('RecoveryExecutor', () {
    late RecoveryExecutor executor;
    late List<String> logMessages;

    setUp(() {
      logMessages = [];
      executor = RecoveryExecutor(
        retryPolicy: const RetryPolicy(
          maxAttempts: 3,
          initialDelay: Duration(milliseconds: 10),
          jitterFactor: 0.0,
        ),
        logger: (message, level) => logMessages.add('[$level] $message'),
      );
    });

    group('executeWithRetry', () {
      test('should succeed on first attempt', () async {
        int attempts = 0;
        final result = await executor.executeWithRetry(
          () async {
            attempts++;
            return 'success';
          },
          operationName: 'test operation',
        );

        expect(result.isSuccess, isTrue);
        expect(
            result.when(
              success: (value) => value,
              failure: (_) => null,
            ),
            equals('success'));
        expect(attempts, equals(1));
      });

      test('should retry on retryable errors', () async {
        int attempts = 0;
        final result = await executor.executeWithRetry(
          () async {
            attempts++;
            if (attempts < 3) {
              throw RecordingFailedError(
                code: ErrorCode.networkTimeout,
                message: 'Network timeout',
              );
            }
            return 'success after retries';
          },
        );

        expect(result.isSuccess, isTrue);
        expect(
            result.when(
              success: (value) => value,
              failure: (_) => null,
            ),
            equals('success after retries'));
        expect(attempts, equals(3));
      });

      test('should not retry non-retryable errors', () async {
        int attempts = 0;
        final result = await executor.executeWithRetry(
          () async {
            attempts++;
            throw ModelLoadingFailedError(
              code: ErrorCode.modelNotFound,
              message: 'Model not found',
            );
          },
        );

        expect(result.isFailure, isTrue);
        expect(
            result.when(
              success: (_) => null,
              failure: (exception) => exception.code,
            ),
            equals(ErrorCode.modelNotFound));
        expect(attempts, equals(1));
      });

      test('should fail after max attempts', () async {
        int attempts = 0;
        final result = await executor.executeWithRetry(
          () async {
            attempts++;
            throw RecordingFailedError(
              code: ErrorCode.networkTimeout,
              message: 'Network timeout',
            );
          },
        );

        expect(result.isFailure, isTrue);
        expect(attempts, equals(3));
      });

      test('should handle non-WhisperKitError exceptions', () async {
        final result = await executor.executeWithRetry(
          () async {
            throw Exception('Generic error');
          },
        );

        expect(result.isFailure, isTrue);
        expect(
            result.when(
              success: (_) => null,
              failure: (exception) => exception.code,
            ),
            equals(ErrorCode.transcriptionFailed));
      });

      test('should log operations correctly', () async {
        await executor.executeWithRetry(
          () async => 'success',
          operationName: 'test operation',
        );

        expect(
            logMessages.any((msg) => msg.contains('Executing test operation')),
            isTrue);
        expect(logMessages.any((msg) => msg.contains('attempt 1/3')), isTrue);
      });
    });
  });
}
