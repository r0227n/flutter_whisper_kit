import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFlutterWhisperkit platform = MethodChannelFlutterWhisperkit();
  const MethodChannel channel = MethodChannel('flutter_whisperkit');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'loadModel') {
            return 'Model loaded successfully';
          } else if (methodCall.method == 'transcribeFromFile') {
            return '{"text":"Test transcription","segments":[],"language":"en","timings":{"fullPipeline":1.0}}';
          } else if (methodCall.method == 'startRecording') {
            return 'Recording started';
          } else if (methodCall.method == 'stopRecording') {
            return 'Recording stopped';
          }
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  
  test('loadModel returns success message', () async {
    expect(await platform.loadModel('tiny-en'), 'Model loaded successfully');
  });
  
  test('transcribeFromFile returns properly parsed TranscriptionResult', () async {
    final result = await platform.transcribeFromFile('test.wav');
    expect(result, isNotNull);
    expect(result!.text, 'Test transcription');
    expect(result.language, 'en');
  });
  
  test('startRecording returns success message', () async {
    expect(await platform.startRecording(), 'Recording started');
  });
  
  test('stopRecording returns success message', () async {
    expect(await platform.stopRecording(), 'Recording stopped');
  });
}
