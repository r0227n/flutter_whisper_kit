import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit_apple/src/models/decoding_options.dart';
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
  Future<String?> transcribeFromFile(String filePath, DecodingOptions? options) =>
      Future.value('{"text":"Test transcription","segments":[],"language":"en","timings":{}}');
      
  @override
  Future<String?> startRecording(DecodingOptions options, bool loop) =>
      Future.value('Recording started');
      
  @override
  Future<String?> stopRecording(bool loop) =>
      Future.value('Recording stopped');
      
  @override
  Future<String?> transcribeCurrentBuffer(DecodingOptions options) =>
      Future.value('{"text":"Test transcription","segments":[],"language":"en","timings":{}}');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  test('getPlatformVersion', () async {
    MockFlutterWhisperkitApplePlatform fakePlatform = MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;
    
    expect(await FlutterWhisperkitApplePlatform.instance.getPlatformVersion(), '42');
  });
}
