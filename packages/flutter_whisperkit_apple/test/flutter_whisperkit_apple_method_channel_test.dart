import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWhisperkitApplePlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperkitApplePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> createWhisperKit(String? model, String? modelRepo) =>
      Future.value('WhisperKit created');

  @override
  Future<String?> loadModel(
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  ) => Future.value('Model loaded');

  @override
  Future<String?> transcribeFromFile(String? filePath, Map<String, dynamic>? options) =>
      Future.value('{"text":"Test transcription","segments":[],"language":"en","timings":{}}');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  test('getPlatformVersion', () async {
    MockFlutterWhisperkitApplePlatform fakePlatform = MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;
    
    MethodChannelFlutterWhisperkitApple platform = MethodChannelFlutterWhisperkitApple();
    expect(await platform.getPlatformVersion(), '42');
  });
}
