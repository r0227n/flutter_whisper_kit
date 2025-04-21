import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_platform_interface.dart';
import 'package:flutter_whisperkit_apple/src/models/transcription_result.dart';
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
  Future<String?> loadModel(String? variant, String? modelRepo, bool? redownload, int? storageLocation) => 
      Future.value('Model loaded');
  
  @override
  Future<String?> transcribeCurrentFile(String? filePath) {
    if (filePath == null) {
      return Future.value(null);
    }
    
    // Mock JSON response for a successful transcription
    const mockJson = '''
    {
      "segments": [
        {
          "text": "Hello world.",
          "start": 0.0,
          "end": 2.0
        },
        {
          "text": "This is a test.",
          "start": 2.0,
          "end": 4.0
        }
      ],
      "timings": {
        "audioFile": 0.1,
        "featureExtraction": 0.2,
        "model": 0.3,
        "firstToken": 0.4,
        "decodingLoop": 0.5,
        "totalElapsed": 1.0,
        "tokensPerSecond": 10.0,
        "realTimeFactor": 0.25,
        "speedFactor": 4.0
      }
    }
    ''';
    
    return Future.value(mockJson);
  }
}

void main() {
  final FlutterWhisperkitApplePlatform initialPlatform = FlutterWhisperkitApplePlatform.instance;
  
  test('$MethodChannelFlutterWhisperkitApple is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWhisperkitApple>());
  });
  
  test('transcribeCurrentFile returns JSON string', () async {
    FlutterWhisperkitApple flutterWhisperkitApplePlugin = FlutterWhisperkitApple();
    MockFlutterWhisperkitApplePlatform fakePlatform = MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;
    
    expect(await flutterWhisperkitApplePlugin.transcribeCurrentFile('test.wav'), isNotNull);
    expect(await flutterWhisperkitApplePlugin.transcribeCurrentFile('test.wav'), isA<String>());
  });
  
  test('transcribeCurrentFileAndParse returns parsed TranscriptionResult', () async {
    FlutterWhisperkitApple flutterWhisperkitApplePlugin = FlutterWhisperkitApple();
    MockFlutterWhisperkitApplePlatform fakePlatform = MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;
    
    final result = await flutterWhisperkitApplePlugin.transcribeCurrentFileAndParse('test.wav');
    
    expect(result, isNotNull);
    expect(result, isA<TranscriptionResult>());
    expect(result!.segments.length, 2);
    expect(result.segments[0].text, 'Hello world.');
    expect(result.segments[1].text, 'This is a test.');
    expect(result.timings, isNotNull);
    expect(result.timings!.totalElapsed, 1.0);
    expect(result.text, 'Hello world. This is a test.');
  });
  
  test('transcribeCurrentFile with null path returns null', () async {
    FlutterWhisperkitApple flutterWhisperkitApplePlugin = FlutterWhisperkitApple();
    MockFlutterWhisperkitApplePlatform fakePlatform = MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;
    
    expect(await flutterWhisperkitApplePlugin.transcribeCurrentFile(null), isNull);
  });
}
