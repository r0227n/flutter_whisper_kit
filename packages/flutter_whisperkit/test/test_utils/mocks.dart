import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock implementation of [FlutterWhisperkitPlatform] for testing.
class MockFlutterWhisperkitPlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperkitPlatform {
  
  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
  }) => Future.value('Model loaded');

  @override
  Future<String?> transcribeFromFile(
    String filePath, {
    DecodingOptions options = const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'ja',
      temperature: 0.0,
      temperatureFallbackCount: 5,
      sampleLength: 224,
      usePrefillPrompt: true,
      usePrefillCache: true,
      detectLanguage: true,
      skipSpecialTokens: true,
      withoutTimestamps: true,
      wordTimestamps: true,
      clipTimestamps: [0.0],
      concurrentWorkerCount: 4,
      chunkingStrategy: ChunkingStrategy.vad,
    ),
  }) {
    if (filePath.isEmpty) {
      throw WhisperKitError(
        code: WhisperKitErrorCode.invalidArguments,
        message: 'File path cannot be empty',
      );
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
  Future<String?> startRecording({
    DecodingOptions options = const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'ja',
      temperature: 0.0,
      temperatureFallbackCount: 5,
      sampleLength: 224,
      usePrefillPrompt: true,
      usePrefillCache: true,
      skipSpecialTokens: true,
      withoutTimestamps: false,
      wordTimestamps: true,
      clipTimestamps: [0.0],
      concurrentWorkerCount: 4,
      chunkingStrategy: ChunkingStrategy.vad,
    ),
    bool loop = true,
  }) => Future.value('Recording started');

  @override
  Future<String?> stopRecording({bool loop = true}) => 
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
  
  @override
  Stream<Progress> get modelProgressStream => Stream<Progress>.fromIterable([
    const Progress(
      totalUnitCount: 100,
      completedUnitCount: 50,
      fractionCompleted: 0.5,
      isIndeterminate: false,
    )
  ]);
}

/// Sets up a mock platform for testing.
/// 
/// Returns the mock platform instance.
MockFlutterWhisperkitPlatform setUpMockPlatform() {
  final mockPlatform = MockFlutterWhisperkitPlatform();
  FlutterWhisperkitPlatform.instance = mockPlatform;
  return mockPlatform;
}
