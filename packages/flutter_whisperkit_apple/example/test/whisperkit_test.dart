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
        final Map<Object?, Object?> result = <Object?, Object?>{};
        result['result'] = true;
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
  });

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
      print('WhisperKit initialized successfully: $result');
    } catch (e) {
      fail('WhisperKit initialization failed with error: $e');
    }
  });
}
