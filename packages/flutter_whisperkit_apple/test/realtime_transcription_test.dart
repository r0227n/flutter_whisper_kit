import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_platform_interface.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit_apple/src/models/decoding_options.dart';
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
  Future<String?> loadModel(String? variant, String? modelRepo, bool? redownload,
      int? storageLocation) =>
      Future.value('Model loaded');
  
  @override
  Future<String?> transcribeFromFile(String filePath, DecodingOptions options) =>
      Future.value('{"text":"Hello world","segments":[]}');
  
  @override
  Future<String?> startRecording(DecodingOptions options, bool loop) =>
      Future.value('Recording started');
  
  @override
  Future<String?> stopRecording(bool loop) =>
      Future.value('Recording stopped');
  
  // transcribeCurrentBuffer removed - now private in Swift only
  
  @override
  Stream<String> get transcriptionStream => 
      Stream<String>.fromIterable(['Test transcription']);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  final FlutterWhisperkitApplePlatform initialPlatform =
      FlutterWhisperkitApplePlatform.instance;
  
  test('$MethodChannelFlutterWhisperkitApple is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWhisperkitApple>());
  });
  
  test('startRecording test', () async {
    final MockFlutterWhisperkitApplePlatform fakePlatform =
        MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;
    
    final plugin = FlutterWhisperkitApple();
    expect(await plugin.startRecording(), 'Recording started');
  });
  
  test('stopRecording test', () async {
    final MockFlutterWhisperkitApplePlatform fakePlatform =
        MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;
    
    final plugin = FlutterWhisperkitApple();
    expect(await plugin.stopRecording(), 'Recording stopped');
  });
  
  // transcribeCurrentBuffer test removed - now private in Swift only
}
