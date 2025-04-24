import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_platform_interface.dart';
import 'package:flutter_whisperkit_apple/src/models/decoding_options.dart';
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
  Future<String?> loadModel(
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  ) => Future.value('Model loaded');

  @override
  Future<String?> transcribeFromFile(
    String filePath,
    DecodingOptions? options,
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
      
  // transcribeCurrentBuffer removed - now private in Swift only
}

void main() {
  final FlutterWhisperkitApplePlatform initialPlatform =
      FlutterWhisperkitApplePlatform.instance;

  test('$MethodChannelFlutterWhisperkitApple is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelFlutterWhisperkitApple>(),
    );
  });

  test('transcribeFromFile returns JSON string', () async {
    FlutterWhisperkitApple flutterWhisperkitApplePlugin =
        FlutterWhisperkitApple();
    MockFlutterWhisperkitApplePlatform fakePlatform =
        MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;

    expect(
      await flutterWhisperkitApplePlugin.transcribeFromFile('test.wav'),
      isNotNull,
    );
    expect(
      await flutterWhisperkitApplePlugin.transcribeFromFile('test.wav'),
      isA<TranscriptionResult>(),
    );
  });

  test('transcribeFromFile with DecodingOptions returns JSON string', () async {
    FlutterWhisperkitApple flutterWhisperkitApplePlugin =
        FlutterWhisperkitApple();
    MockFlutterWhisperkitApplePlatform fakePlatform =
        MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;

    final options = DecodingOptions(
      language: 'en',
      temperature: 0.7,
      wordTimestamps: true,
    );

    expect(
      await flutterWhisperkitApplePlugin.transcribeFromFile(
        'test.wav',
        options: options,
      ),
      isNotNull,
    );
    expect(
      await flutterWhisperkitApplePlugin.transcribeFromFile(
        'test.wav',
        options: options,
      ),
      isA<TranscriptionResult>(),
    );
  });

  test('transcribeFromFile with empty path throws exception', () async {
    FlutterWhisperkitApple flutterWhisperkitApplePlugin =
        FlutterWhisperkitApple();
    MockFlutterWhisperkitApplePlatform fakePlatform =
        MockFlutterWhisperkitApplePlatform();
    FlutterWhisperkitApplePlatform.instance = fakePlatform;

    expect(
      () => flutterWhisperkitApplePlugin.transcribeFromFile(''),
      throwsException,
    );
  });

  test('DecodingOptions creates correct options object', () {
    final options = DecodingOptions(
      task: DecodingTask.transcribe,
      language: 'en',
      temperature: 0.7,
      sampleLength: 100,
      temperatureFallbackCount: 5,
      usePrefillPrompt: true,
      usePrefillCache: true,
      detectLanguage: true,
      skipSpecialTokens: true,
      withoutTimestamps: false,
      maxInitialTimestamp: 1.0,
      wordTimestamps: true,
      clipTimestamps: [0.0],
      concurrentWorkerCount: 4,
      chunkingStrategy: ChunkingStrategy.vad,
    );

    expect(options, isA<DecodingOptions>());
    expect(options.task, DecodingTask.transcribe);
    expect(options.language, 'en');
    expect(options.temperature, 0.7);
    expect(options.sampleLength, 100);
    expect(options.temperatureFallbackCount, 5);
    expect(options.usePrefillPrompt, true);
    expect(options.usePrefillCache, true);
    expect(options.detectLanguage, true);
    expect(options.skipSpecialTokens, true);
    expect(options.withoutTimestamps, false);
    expect(options.maxInitialTimestamp, 1.0);
    expect(options.wordTimestamps, true);
    expect(options.chunkingStrategy, ChunkingStrategy.vad);

    // Test toJson method
    final json = options.toJson();
    expect(json, isA<Map<String, dynamic>>());
    expect(json['task'], 'transcribe');
    expect(json['language'], 'en');
    expect(json['temperature'], 0.7);
  });
}
