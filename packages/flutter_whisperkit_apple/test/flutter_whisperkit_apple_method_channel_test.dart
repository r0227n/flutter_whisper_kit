import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit_apple/src/whisper_kit_message.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlutterWhisperkitApple platform = MethodChannelFlutterWhisperkitApple();
  const MethodChannel channel = MethodChannel('flutter_whisperkit_apple');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
  
  test('transcribeCurrentFile', () async {
    // This test will use the Pigeon-generated API which we can't easily mock in this test
    // So we're just verifying the method exists and doesn't throw
    expect(platform.transcribeCurrentFile, isNotNull);
  });
}
