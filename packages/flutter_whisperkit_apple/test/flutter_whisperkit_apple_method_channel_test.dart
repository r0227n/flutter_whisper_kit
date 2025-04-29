import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit_apple/src/models/decoding_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelFlutterWhisperkitApple', () {
    late MethodChannelFlutterWhisperkitApple platform;
    const MethodChannel channel = MethodChannel('flutter_whisperkit_apple');

    setUp(() {
      platform = MethodChannelFlutterWhisperkitApple();
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'loadModel':
              return 'Model loaded';
            case 'transcribeFromFile':
              return '{"text":"Test transcription","segments":[],"language":"en","timings":{}}';
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });

    test('channel is correctly initialized', () {
      // Assert
      expect(platform.methodChannel.name, 'flutter_whisperkit_apple');
      expect(platform.transcriptionStreamChannel.name, 'flutter_whisperkit_apple/transcription_stream');
    });
  });
}
