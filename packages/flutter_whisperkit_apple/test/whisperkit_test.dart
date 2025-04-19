import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterWhisperkitApple whisperKit;
  
  setUp(() {
    whisperKit = FlutterWhisperkitApple();
    
    // Set up mock response for the BasicMessageChannel
    const channelName = 'dev.flutter.pigeon.flutter_whisperkit_apple.WhisperKitApi.initializeWhisperKit';
    final codec = const StandardMethodCodec();
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      channelName,
      (ByteData? message) async {
        // Return success response
        return codec.encodeSuccessEnvelope(<Object?>[true]);
      },
    );
    
    // Set up mock for getAvailableModels
    const modelsChannelName = 'dev.flutter.pigeon.flutter_whisperkit_apple.WhisperKitApi.getAvailableModels';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      modelsChannelName,
      (ByteData? message) async {
        final List<String> models = ['tiny', 'base', 'small', 'medium', 'large'];
        return codec.encodeSuccessEnvelope(<Object?>[models]);
      },
    );
    
    // Set up mock for transcribeAudioFile
    const transcribeChannelName = 'dev.flutter.pigeon.flutter_whisperkit_apple.WhisperKitApi.transcribeAudioFile';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      transcribeChannelName,
      (ByteData? message) async {
        final mockResult = TranscriptionResult(
          text: "This is a mock transcription result",
          segments: [
            TranscriptionSegment(
              text: "This is a mock transcription result",
              startTime: 0.0,
              endTime: 2.0
            )
          ],
          language: "en"
        );
        return codec.encodeSuccessEnvelope(<Object?>[mockResult]);
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'dev.flutter.pigeon.flutter_whisperkit_apple.WhisperKitApi.initializeWhisperKit',
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'dev.flutter.pigeon.flutter_whisperkit_apple.WhisperKitApi.getAvailableModels',
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'dev.flutter.pigeon.flutter_whisperkit_apple.WhisperKitApi.transcribeAudioFile',
      null,
    );
  });

  group('WhisperKit API Tests', () {
    test('initializeWhisperKit should complete successfully', () async {
      // Skip the test in a real environment
      if (!TestWidgetsFlutterBinding.ensureInitialized().inTest) {
        return;
      }
      
      try {
        final config = WhisperKitConfig(
          enableVAD: true,
          vadFallbackSilenceThreshold: 600,
          vadTemperature: 0.15,
          enableLanguageIdentification: true,
        );

        // This should now use our mock handler
        final result = await whisperKit.initializeWhisperKit(config: config);
        expect(result, isTrue);
      } catch (e) {
        fail('WhisperKit initialization failed with error: $e');
      }
    });

    test('getAvailableModels should return a list of models', () async {
      // Skip the test in a real environment
      if (!TestWidgetsFlutterBinding.ensureInitialized().inTest) {
        return;
      }
      
      try {
        final models = await whisperKit.getAvailableModels();
        expect(models, isA<List<String>>());
        expect(models, contains('tiny'));
        expect(models, contains('base'));
        expect(models, contains('small'));
        expect(models, contains('medium'));
        expect(models, contains('large'));
      } catch (e) {
        fail('getAvailableModels failed with error: $e');
      }
    });

    test('transcribeAudioFile should return a transcription result', () async {
      // Skip the test in a real environment
      if (!TestWidgetsFlutterBinding.ensureInitialized().inTest) {
        return;
      }
      
      try {
        final result = await whisperKit.transcribeAudioFile('test_audio.wav');
        expect(result, isA<TranscriptionResult>());
        expect(result.text, isNotEmpty);
        expect(result.segments, isNotEmpty);
      } catch (e) {
        fail('transcribeAudioFile failed with error: $e');
      }
    });
  });
}
