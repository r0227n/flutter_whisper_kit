import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_platform_interface.dart';
import 'test_utils/mock_platform.dart';

void main() {
  group('Error Recovery Integration Tests', () {
    late FlutterWhisperKit whisperKit;
    late MockFlutterWhisperKitPlatform mockPlatform;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      whisperKit = FlutterWhisperKit();
      mockPlatform = MockFlutterWhisperKitPlatform();
      mockPlatform.resetMock();
      FlutterWhisperKitPlatform.instance = mockPlatform;
    });

    tearDown(() {
      mockPlatform.dispose();
    });

    group('Full error recovery workflow', () {
      test('should retry model loading with exponential backoff', () async {
        final configuration = WhisperKitConfiguration(
          errorRecovery: ErrorRecoveryStrategy.automatic(
            retryPolicy: const RetryPolicy(
              maxAttempts: 3,
              initialDelay: Duration(milliseconds: 100),
              backoffMultiplier: 2.0,
            ),
          ),
          retryPolicy: const RetryPolicy(maxAttempts: 3),
          fallbackOptions: const FallbackOptions(),
          enableLogging: true,
          logLevel: LogLevel.debug,
        );

        final executor = RecoveryExecutor(
          retryPolicy: configuration.retryPolicy,
          logger: (message, level) {
            // In a real implementation, this would log to console or file
            // print('[${level.name}] $message');
          },
        );

        // Example: Retry model loading with recovery
        final result = await executor.executeWithRetry<String>(
          () async {
            // Simulate operation that might fail
            final loadResult = await whisperKit.loadModelWithResult('tiny');
            return loadResult.when(
              success: (path) => path,
              failure: (exception) => throw exception,
            );
          },
          operationName: 'model loading',
        );

        expect(result, isA<Result<String, WhisperKitError>>());
      });

      test('should apply fallback options on transcription failure', () async {
        final fallbackOptions = FallbackOptions(
          useOfflineModel: true,
          offlineModelVariant: 'tiny',
          degradeQuality: true,
          skipWordTimestamps: true,
          reduceConcurrency: true,
        );

        final originalOptions = const DecodingOptions(
          task: DecodingTask.transcribe,
          language: 'en',
          temperature: 0.0,
          wordTimestamps: true,
          topK: 5,
          concurrentWorkerCount: 4,
        );

        // Apply fallback options
        final fallbackDecodingOptions = fallbackOptions.applyToDecodingOptions(originalOptions);

        // Verify fallback options are applied correctly
        expect(fallbackDecodingOptions.wordTimestamps, isFalse);
        expect(fallbackDecodingOptions.topK, equals(1));
        expect(fallbackDecodingOptions.sampleLength, equals(224));
        expect(fallbackDecodingOptions.concurrentWorkerCount, equals(1));

        // Example: Use fallback options in transcription
        final transcriptionResult = await whisperKit.transcribeFileWithResult(
          '/path/to/audio.wav',
          options: fallbackDecodingOptions,
        );

        expect(transcriptionResult, isA<Result<TranscriptionResult?, WhisperKitError>>());
      });

      test('should handle custom recovery strategy', () async {
        int recoveryAttempts = 0;
        
        final customStrategy = ErrorRecoveryStrategy.custom(
          onError: (error) async {
            recoveryAttempts++;
            
            // Custom recovery logic based on error type
            if (error.code == ErrorCode.networkTimeout) {
              // Wait and retry
              await Future.delayed(const Duration(seconds: 1));
              return RecoveryAction.retry;
            } else if (error.code == ErrorCode.insufficientMemory) {
              // Use fallback
              return RecoveryAction.fallback;
            } else {
              // Fail immediately for other errors
              return RecoveryAction.fail;
            }
          },
          retryPolicy: const RetryPolicy(maxAttempts: 5),
          fallbackOptions: const FallbackOptions(degradeQuality: true),
        );

        // Simulate recovery execution
        expect(customStrategy.type, equals(RecoveryType.custom));
        expect(customStrategy.onError, isNotNull);

        // Test the custom error handler
        final networkError = WhisperKitError(
          code: ErrorCode.networkTimeout,
          message: 'Network timeout',
        );
        
        final action = await customStrategy.onError!(networkError);
        expect(action, equals(RecoveryAction.retry));
        expect(recoveryAttempts, equals(1));
      });

      test('should use production configuration for robust error handling', () async {
        final prodConfig = WhisperKitConfiguration.production();

        expect(prodConfig.errorRecovery.type, equals(RecoveryType.automatic));
        expect(prodConfig.errorRecovery.retryPolicy.maxAttempts, equals(3));
        expect(prodConfig.errorRecovery.fallbackOptions?.useOfflineModel, isTrue);
        expect(prodConfig.errorRecovery.fallbackOptions?.degradeQuality, isTrue);
        expect(prodConfig.enableLogging, isTrue);
        expect(prodConfig.logLevel, equals(LogLevel.warning));

        // Example: Use production configuration for transcription
        final executor = RecoveryExecutor(
          retryPolicy: prodConfig.retryPolicy,
          fallbackOptions: prodConfig.fallbackOptions,
          logger: prodConfig.enableLogging
              ? (message, level) {
                  if (level.index >= prodConfig.logLevel.index) {
                    // print('[${level.name}] $message');
                  }
                }
              : null,
        );

        final result = await executor.executeWithRetry<TranscriptionResult?>(
          () async {
            final transcriptionResult = await whisperKit.transcribeFileWithResult(
              '/path/to/audio.wav',
            );
            
            return transcriptionResult.when(
              success: (result) => result,
              failure: (exception) => throw exception,
            );
          },
          operationName: 'audio transcription',
        );

        expect(result, isA<Result<TranscriptionResult?, WhisperKitError>>());
      });

      test('should handle multiple retry attempts with jitter', () async {
        final retryPolicy = RetryPolicy(
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 100),
          maxDelay: const Duration(seconds: 1),
          backoffMultiplier: 2.0,
          jitterFactor: 0.2,
        );

        final delays = <Duration>[];
        
        // Simulate multiple attempts
        for (int i = 0; i < 3; i++) {
          final delay = retryPolicy.getDelayForAttempt(i);
          delays.add(delay);
        }

        // Verify delays increase with backoff
        expect(delays[0].inMilliseconds, greaterThanOrEqualTo(80)); // 100ms - 20%
        expect(delays[0].inMilliseconds, lessThanOrEqualTo(120)); // 100ms + 20%
        
        expect(delays[1].inMilliseconds, greaterThanOrEqualTo(160)); // 200ms - 20%
        expect(delays[1].inMilliseconds, lessThanOrEqualTo(240)); // 200ms + 20%
        
        expect(delays[2].inMilliseconds, greaterThanOrEqualTo(320)); // 400ms - 20%
        expect(delays[2].inMilliseconds, lessThanOrEqualTo(480)); // 400ms + 20%
      });

      test('should combine Result API with recovery for complete error handling', () async {
        final logMessages = <String>[];
        
        final executor = RecoveryExecutor(
          retryPolicy: const RetryPolicy(
            maxAttempts: 2,
            initialDelay: Duration(milliseconds: 50),
          ),
          logger: (message, level) => logMessages.add('[$level] $message'),
        );

        // Simulate language detection with recovery
        final result = await executor.executeWithRetry<LanguageDetectionResult?>(
          () async {
            final detectionResult = await whisperKit.detectLanguageWithResult(
              '/path/to/audio.wav',
            );
            
            return detectionResult.when(
              success: (result) => result,
              failure: (exception) {
                // Check if error is recoverable
                if (ErrorCode.isRecoverable(exception.code)) {
                  throw exception;
                } else {
                  // Return null for non-recoverable errors
                  return null;
                }
              },
            );
          },
          operationName: 'language detection',
        );

        // Verify logging occurred
        expect(logMessages.any((msg) => msg.contains('language detection')), isTrue);
        expect(result, isA<Result<LanguageDetectionResult?, WhisperKitError>>());
      });
    });

    group('Error code based recovery', () {
      test('should identify and handle recoverable errors', () async {
        final recoverableErrors = [
          ErrorCode.networkTimeout,
          ErrorCode.networkUnavailable,
          ErrorCode.downloadFailed,
          ErrorCode.transcriptionFailed,
          ErrorCode.audioProcessingError,
        ];

        for (final errorCode in recoverableErrors) {
          expect(ErrorCode.isRecoverable(errorCode), isTrue);
          
          final error = ErrorCode.createError(errorCode);
          expect(error.code, equals(errorCode));
          expect(error.message, equals(ErrorCode.getDescription(errorCode)));
        }
      });

      test('should not retry non-recoverable errors', () async {
        final nonRecoverableErrors = [
          ErrorCode.modelNotFound,
          ErrorCode.invalidConfiguration,
          ErrorCode.microphonePermissionDenied,
          ErrorCode.invalidAudioFormat,
        ];

        for (final errorCode in nonRecoverableErrors) {
          expect(ErrorCode.isRecoverable(errorCode), isFalse);
          
          final suggestedAction = ErrorCode.getSuggestedAction(errorCode);
          expect(suggestedAction, isNotEmpty);
        }
      });
    });

    group('Integration with WhisperKit configuration', () {
      test('should create default configuration with basic recovery', () {
        final config = WhisperKitConfiguration.defaultConfig();
        
        expect(config.errorRecovery.type, equals(RecoveryType.automatic));
        expect(config.retryPolicy.maxAttempts, equals(3));
        expect(config.fallbackOptions.useOfflineModel, isFalse);
        expect(config.enableLogging, isFalse);
      });

      test('should support manual recovery strategy', () {
        final config = WhisperKitConfiguration(
          errorRecovery: ErrorRecoveryStrategy.manual(),
          retryPolicy: const RetryPolicy(maxAttempts: 0),
          fallbackOptions: const FallbackOptions(),
        );
        
        expect(config.errorRecovery.type, equals(RecoveryType.manual));
        expect(config.errorRecovery.retryPolicy.maxAttempts, equals(0));
      });
    });
  });
}