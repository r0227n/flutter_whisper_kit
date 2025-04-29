import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock implementation of [FlutterWhisperkitApplePlatform] for testing.
class MockFlutterWhisperkitApplePlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperkitApplePlatform {
  
  @override
  Future<String?> loadModel(
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  ) => Future.value('Model loaded');

  @override
  Future<String?> transcribeFromFile(
    String filePath,
    DecodingOptions options,
  ) {
    if (filePath.isEmpty) {
      return Future.value(null);
    }

    // Mock JSON response for a successful transcription
    const mockJson = '''
    {
      "text": "Hello world. This is a test.",
      "segments": [
        {
          "id": 0,
          "seek": 0,
          "text": "Hello world.",
          "start": 0.0,
          "end": 2.0,
          "tokens": [1, 2, 3],
          "temperature": 1.0,
          "avgLogprob": -0.5,
          "compressionRatio": 1.2,
          "noSpeechProb": 0.1
        },
        {
          "id": 1,
          "seek": 0,
          "text": "This is a test.",
          "start": 2.0,
          "end": 4.0,
          "tokens": [4, 5, 6, 7],
          "temperature": 1.0,
          "avgLogprob": -0.4,
          "compressionRatio": 1.3,
          "noSpeechProb": 0.05
        }
      ],
      "language": "en",
      "timings": {
        "pipelineStart": 0.0,
        "firstTokenTime": 0.4,
        "inputAudioSeconds": 4.0,
        "audioLoading": 0.1,
        "audioProcessing": 0.2,
        "encoding": 0.3,
        "decodingLoop": 0.5,
        "fullPipeline": 1.0
      }
    }
    ''';

    return Future.value(mockJson);
  }

  @override
  Future<String?> startRecording(DecodingOptions options, bool loop) =>
      Future.value('Recording started');

  @override
  Future<String?> stopRecording(bool loop) => 
      Future.value('Recording stopped');

  @override
  Stream<TranscriptionResult> get transcriptionStream => Stream<TranscriptionResult>.fromIterable([
    TranscriptionResult.fromJsonString('''
      {
        "text": "Test transcription",
        "segments": [
          {
            "id": 0,
            "seek": 0,
            "text": "Test transcription",
            "start": 0.0,
            "end": 2.0,
            "tokens": [1, 2, 3],
            "temperature": 1.0,
            "avgLogprob": -0.5,
            "compressionRatio": 1.2,
            "noSpeechProb": 0.1
          }
        ],
        "language": "en",
        "timings": {
          "fullPipeline": 1.0
        }
      }
    ''')
  ]);
}

/// Sets up a mock platform for testing.
/// 
/// Returns the mock platform instance.
MockFlutterWhisperkitApplePlatform setUpMockPlatform() {
  final mockPlatform = MockFlutterWhisperkitApplePlatform();
  FlutterWhisperkitApplePlatform.instance = mockPlatform;
  return mockPlatform;
}
