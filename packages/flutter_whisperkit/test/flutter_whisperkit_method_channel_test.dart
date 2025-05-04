import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';
import 'package:flutter_whisperkit/src/models.dart';
import 'test_utils/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMethodChannelFlutterWhisperkit whisperKit;

  setUp(() {
    whisperKit = MockMethodChannelFlutterWhisperkit();
  });

  group('MethodChannelFlutterWhisperKit', () {
    test('loadModel returns model path when successful', () async {
      const expectedPath = '/path/to/model';
      whisperKit.mockLoadModelResponse = expectedPath;

      final result = await whisperKit.loadModel('tiny');
      expect(result, equals(expectedPath));
    });

    test(
      'transcribeFromFile returns TranscriptionResult when successful',
      () async {
        const testFilePath = '/path/to/audio.wav';
        final expectedResult = TranscriptionResult(
          text: 'Hello world',
          segments: [],
          language: 'en',
          timings: const TranscriptionTimings(),
        );
        whisperKit.mockTranscribeResponse = expectedResult;

        final result = await whisperKit.transcribeFromFile(testFilePath);
        expect(result?.text, equals(expectedResult.text));
      },
    );

    test('startRecording returns success message', () async {
      const expectedMessage = 'Recording started';
      whisperKit.mockStartRecordingResponse = expectedMessage;

      final result = await whisperKit.startRecording();
      expect(result, equals(expectedMessage));
    });

    test('stopRecording returns success message', () async {
      const expectedMessage = 'Recording stopped';
      whisperKit.mockStopRecordingResponse = expectedMessage;

      final result = await whisperKit.stopRecording();
      expect(result, equals(expectedMessage));
    });
  });
}
