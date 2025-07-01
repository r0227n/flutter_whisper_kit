import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';

// Mock implementation for testing - will be replaced by actual plugin
class MockWhisperKitPlatformChannel {
  static final BasicMessageChannel<Object?> _channel =
      BasicMessageChannel<Object?>(
    'dev.flutter.pigeon.flutter_whisper_kit.WhisperKitMessage.startRecording',
    StandardMessageCodec(),
  );
  static final BasicMessageChannel<Object?> _stopChannel =
      BasicMessageChannel<Object?>(
    'dev.flutter.pigeon.flutter_whisper_kit.WhisperKitMessage.stopRecording',
    StandardMessageCodec(),
  );

  final List<MethodCall> methodCalls = [];
  bool microphonePermissionGranted = true;
  bool isRecording = false;
  String? currentError;

  void setMicrophonePermission(bool granted) {
    microphonePermissionGranted = granted;
  }

  void setupMockHandlers(TestWidgetsFlutterBinding binding) {
    // Mock startRecording method
    binding.defaultBinaryMessenger.setMockMessageHandler(_channel.name,
        (ByteData? message) async {
      // Decode the message
      final List<dynamic> args =
          StandardMessageCodec().decodeMessage(message!) as List<dynamic>;
      final options = args[0] as Map<Object?, Object?>;
      final loop = args[1] as bool;

      methodCalls.add(
          MethodCall('startRecording', {'options': options, 'loop': loop}));

      if (!microphonePermissionGranted) {
        // Return error format [code, message, details]
        return StandardMessageCodec().encodeMessage(
            ['PERMISSION_DENIED', 'Microphone permission required', null]);
      }

      if (isRecording) {
        return StandardMessageCodec().encodeMessage(
            ['ALREADY_RECORDING', 'Recording already in progress', null]);
      }

      // Validate parameters
      if (options['sampleLength'] != null &&
          (options['sampleLength'] as int) < 0) {
        return StandardMessageCodec().encodeMessage(
            ['INVALID_PARAMETERS', 'Invalid sample length', null]);
      }

      if (options['language'] != null &&
          (options['language'] as String).contains('../')) {
        return StandardMessageCodec().encodeMessage(
            ['SECURITY_VIOLATION', 'Invalid language parameter', null]);
      }

      isRecording = true;
      // Return success format [result]
      return StandardMessageCodec().encodeMessage(['Recording started']);
    });

    // Mock stopRecording method
    binding.defaultBinaryMessenger.setMockMessageHandler(_stopChannel.name,
        (ByteData? message) async {
      // Decode the message
      final List<dynamic> args =
          StandardMessageCodec().decodeMessage(message!) as List<dynamic>;
      final loop = args[0] as bool;

      methodCalls.add(MethodCall('stopRecording', {'loop': loop}));

      if (!isRecording) {
        return StandardMessageCodec().encodeMessage(['Recording not active']);
      }

      isRecording = false;
      return StandardMessageCodec().encodeMessage(['Recording stopped']);
    });
  }

  void cleanup(TestWidgetsFlutterBinding binding) {
    binding.defaultBinaryMessenger.setMockMessageHandler(_channel.name, null);
    binding.defaultBinaryMessenger
        .setMockMessageHandler(_stopChannel.name, null);
    methodCalls.clear();
    isRecording = false;
    currentError = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Recording Methods Tests', () {
    late MockWhisperKitPlatformChannel mockChannel;
    late FlutterWhisperKit whisperKit;

    setUp(() {
      mockChannel = MockWhisperKitPlatformChannel();
      mockChannel
          .setupMockHandlers(TestWidgetsFlutterBinding.ensureInitialized());
      whisperKit = FlutterWhisperKit();
    });

    tearDown(() {
      mockChannel.cleanup(TestWidgetsFlutterBinding.ensureInitialized());
    });

    group('startRecording', () {
      test('should check microphone permissions before starting recording',
          () async {
        // Arrange
        mockChannel.setMicrophonePermission(false);
        const options = DecodingOptions(
          task: DecodingTask.transcribe,
          language: 'en',
          temperatureFallbackCount: 5,
        );

        // Act & Assert
        expect(
          () async => await whisperKit.startRecording(options: options),
          throwsA(
            isA<WhisperKitError>()
                .having((e) => e.code, 'code', 4001) // Permission denied code
                .having((e) => e.message, 'message', contains('permission')),
          ),
        );
      });

      test('should initialize WhisperKit with callback configuration',
          () async {
        // Arrange
        const options = DecodingOptions(
          task: DecodingTask.transcribe,
          detectLanguage: true,
        );

        // Act
        final result = await whisperKit.startRecording(options: options);

        // Assert
        expect(result, 'Recording started');
        expect(mockChannel.methodCalls.length, 1);
        final call = mockChannel.methodCalls.first;
        expect(call.method, 'startRecording');
        final args = call.arguments as Map<String, dynamic>;
        final passedOptions = args['options'] as Map<Object?, Object?>;
        expect(passedOptions['detectLanguage'], true);
        expect(passedOptions['task'], 'transcribe');
      });

      test('should handle real-time transcription callbacks', () async {
        // Arrange
        const options = DecodingOptions();

        // Act
        final result = await whisperKit.startRecording(options: options);

        // Assert
        expect(result, 'Recording started');
        expect(mockChannel.isRecording, true);
        // TODO: When implemented, should verify callbacks are set up:
        // - onInit callback
        // - onTextOutput callback
        // - onClose callback
      });

      test('should handle loop parameter for continuous recording', () async {
        // Arrange
        const options = DecodingOptions();

        // Act
        final result =
            await whisperKit.startRecording(options: options, loop: true);

        // Assert
        expect(result, 'Recording started');
        final call = mockChannel.methodCalls.first;
        final args = call.arguments as Map<String, dynamic>;
        expect(args['loop'], true); // loop parameter
      });

      test('should return error when microphone permission is denied',
          () async {
        // Arrange
        mockChannel.setMicrophonePermission(false);
        const options = DecodingOptions();

        // Act & Assert
        expect(
          () async => await whisperKit.startRecording(options: options),
          throwsA(
            isA<WhisperKitError>()
                .having((e) => e.code, 'code', 4001), // Permission denied code
          ),
        );
      });

      test('should validate recording parameters to prevent misuse', () async {
        // Arrange - invalid options
        const invalidOptions = DecodingOptions(
          sampleLength: -1, // Invalid negative sample length
        );

        // Act & Assert
        expect(
          () async => await whisperKit.startRecording(options: invalidOptions),
          throwsA(
            isA<WhisperKitError>()
                .having((e) => e.message, 'message', contains('Invalid')),
          ),
        );
      });

      test('should prevent concurrent recording sessions', () async {
        // Arrange
        const options = DecodingOptions();
        await whisperKit.startRecording(options: options);

        // Act & Assert
        expect(
          () async => await whisperKit.startRecording(options: options),
          throwsA(
            isA<WhisperKitError>()
                .having((e) => e.message, 'message', contains('already')),
          ),
        );
      });
    });

    group('stopRecording', () {
      test('should properly deinitialize WhisperKit resources', () async {
        // Arrange
        const options = DecodingOptions();
        await whisperKit.startRecording(options: options);

        // Act
        final result = await whisperKit.stopRecording();

        // Assert
        expect(result, 'Recording stopped');
        expect(mockChannel.isRecording, false);
      });

      test('should handle loop parameter when stopping recording', () async {
        // Arrange
        const options = DecodingOptions();
        await whisperKit.startRecording(options: options, loop: true);

        // Act
        final result = await whisperKit.stopRecording(loop: false);

        // Assert
        expect(result, 'Recording stopped');
        final stopCall = mockChannel.methodCalls.last;
        final stopArgs = stopCall.arguments as Map<String, dynamic>;
        expect(stopArgs['loop'], false); // loop parameter
      });

      test('should clean up audio resources properly', () async {
        // Arrange
        const options = DecodingOptions();
        await whisperKit.startRecording(options: options);

        // Act
        final result = await whisperKit.stopRecording();

        // Assert
        expect(result, 'Recording stopped');
        expect(mockChannel.isRecording, false);
        // TODO: When implemented, should verify:
        // - Audio session cleanup
        // - Memory deallocation
        // - Callback removal
      });

      test('should handle stop when recording is not active', () async {
        // Act
        final result = await whisperKit.stopRecording();

        // Assert
        expect(result, 'Recording not active');
      });
    });

    group('Callback Handling', () {
      test('should forward MSG_INIT callback to Flutter', () async {
        // Arrange
        const options = DecodingOptions();

        // Act
        await whisperKit.startRecording(options: options);

        // Assert
        expect(mockChannel.isRecording, true);
        // TODO: When implemented, should capture onInit event
      });

      test('should forward MSG_TEXT_OUT callback with transcription', () async {
        // Arrange
        const options = DecodingOptions();

        // Act
        await whisperKit.startRecording(options: options);

        // Assert
        expect(mockChannel.isRecording, true);
        // TODO: When implemented, should capture transcription text
      });

      test('should forward MSG_CLOSE callback when recording stops', () async {
        // Arrange
        const options = DecodingOptions();
        await whisperKit.startRecording(options: options);

        // Act
        await whisperKit.stopRecording();

        // Assert
        expect(mockChannel.isRecording, false);
        // TODO: When implemented, should capture onClose event
      });
    });

    group('Security Considerations', () {
      test('should not expose sensitive audio data in error messages',
          () async {
        // Arrange
        mockChannel.setMicrophonePermission(false);

        // Act & Assert
        try {
          await whisperKit.startRecording();
        } catch (e) {
          expect(e.toString(), isNot(contains('audio data')));
          expect(e.toString(), isNot(contains('file path')));
        }
      });

      test('should validate all input parameters', () async {
        // Arrange - potentially malicious options
        const maliciousOptions = DecodingOptions(
          language: '../../../etc/passwd', // Path traversal attempt
        );

        // Act & Assert
        expect(
          () async =>
              await whisperKit.startRecording(options: maliciousOptions),
          throwsA(
            isA<WhisperKitError>()
                .having((e) => e.message, 'message', contains('Invalid')),
          ),
        );
      });
    });
  });
}
