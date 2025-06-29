import 'dart:async';

import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock implementation of [FlutterWhisperKitPlatform] for testing.
class MockFlutterWhisperkitPlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperKitPlatform {
  MockFlutterWhisperkitPlatform()
      : _progressController = StreamController<Progress>.broadcast(),
        _transcriptionController =
            StreamController<TranscriptionResult>.broadcast();

  /// Exception to throw for testing error handling
  Exception? _throwError;

  /// Stream controllers for testing
  final StreamController<Progress> _progressController;
  final StreamController<TranscriptionResult> _transcriptionController;

  /// Stream controller getter for testing
  StreamController<Progress> get progressController => _progressController;

  /// Stream controller getter for testing
  StreamController<TranscriptionResult> get transcriptionController =>
      _transcriptionController;

  /// Set an error to throw for testing error handling
  void setThrowError(Exception? error) {
    _throwError = error;
  }

  /// Emit progress updates for testing
  void emitProgressUpdates() {
    Future.delayed(const Duration(milliseconds: 10), () {
      _progressController.add(const Progress(
        fractionCompleted: 0.25,
        completedUnitCount: 25,
        totalUnitCount: 100,
      ));
    });
    Future.delayed(const Duration(milliseconds: 20), () {
      _progressController.add(const Progress(
        fractionCompleted: 0.5,
        completedUnitCount: 50,
        totalUnitCount: 100,
      ));
    });
    Future.delayed(const Duration(milliseconds: 30), () {
      _progressController.add(const Progress(
        fractionCompleted: 1.0,
        completedUnitCount: 100,
        totalUnitCount: 100,
      ));
    });
  }

  /// Check if an error should be thrown
  void _checkThrowError() {
    if (_throwError != null) {
      final error = _throwError!;
      _throwError = null; // Reset after throwing
      throw error;
    }
  }

  @override
  Future<String> deviceName() {
    _checkThrowError();
    return Future.value('Mock Device');
  }

  @override
  Future<ModelSupport> recommendedModels() {
    _checkThrowError();
    return Future.value(
      ModelSupport(
        defaultModel: 'openai_whisper-base',
        supported: [
          'openai_whisper-tiny',
          'openai_whisper-base',
          'openai_whisper-small'
        ],
        disabled: [],
      ),
    );
  }

  @override
  Future<LanguageDetectionResult> detectLanguage(String audioPath) {
    _checkThrowError();
    return Future.value(
      LanguageDetectionResult(
        language: 'en',
        probabilities: {'en': 0.95, 'ja': 0.05},
      ),
    );
  }

  @override
  Future<List<String>> formatModelFiles(List<String> modelPaths) {
    _checkThrowError();
    return Future.value(
      modelPaths.map((path) => 'formatted_$path').toList(),
    );
  }

  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
  }) {
    _checkThrowError();
    final modelPath = 'whisperkit-coreml/openai_whisper-${variant ?? 'base'}';
    return Future.value(modelPath);
  }

  @override
  Future<TranscriptionResult?> transcribeFromFile(
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
    _checkThrowError();

    if (filePath.isEmpty || filePath.contains('../')) {
      throw InvalidArgumentsError(
          message: 'File path cannot be empty', code: 5003);
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

    return Future.value(TranscriptionResult.fromJsonString(mockJson));
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
  }) {
    _checkThrowError();
    return Future.value('Recording started');
  }

  @override
  Future<String?> stopRecording({bool loop = true}) {
    _checkThrowError();
    return Future.value('Recording stopped');
  }

  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _transcriptionController.stream;

  @override
  Stream<Progress> get modelProgressStream => _progressController.stream;

  @override
  Future<List<String>> fetchAvailableModels({
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    List<String> matching = const ['*'],
    String? token,
  }) {
    _checkThrowError();
    if (modelRepo.startsWith('http://127.0.0.1') ||
        modelRepo.startsWith('file://')) {
      throw InvalidArgumentsError(message: 'Invalid modelRepo', code: 5002);
    }
    return Future.value([
      'tiny',
      'tiny.en',
      'base',
      'base.en',
      'small',
      'small.en',
      'medium',
      'medium.en',
      'large-v2',
      'large-v3',
    ]);
  }

  @override
  Future<ModelSupportConfig> fetchModelSupportConfig({
    String? downloadBase,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
  }) {
    _checkThrowError();
    return Future.value(
      ModelSupportConfig(
        repoName: repo,
        repoVersion: '1.0.0',
        deviceSupports: [
          DeviceSupport(
            chips: 'A12, A13',
            identifiers: ['iPhone12,1', 'iPhone12,3'],
            models: ModelSupport(
              defaultModel: 'tiny',
              supported: ['tiny', 'base', 'small', 'medium', 'large'],
              disabled: [],
            ),
          ),
        ],
        knownModels: ['tiny', 'base', 'small', 'medium', 'large'],
        defaultSupport: ModelSupport(
          defaultModel: 'tiny',
          supported: ['tiny', 'base', 'small', 'medium', 'large'],
          disabled: [],
        ),
      ),
    );
  }

  @override
  Future<ModelSupport> recommendedRemoteModels({
    String? downloadBase,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
  }) =>
      Future.value(
        ModelSupport(
          defaultModel: 'tiny',
          supported: ['tiny', 'base', 'small', 'medium', 'large'],
          disabled: [],
        ),
      );

  @override
  Future<String?> setupModels({
    String? model,
    String? downloadBase,
    String? modelRepo,
    String? modelToken,
    String? modelFolder,
    bool download = true,
  }) {
    _checkThrowError();
    return Future.value('Models set up successfully');
  }

  @override
  Future<String?> download({
    required String variant,
    String? downloadBase,
    bool useBackgroundSession = false,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
  }) {
    _checkThrowError();
    return Future.value('/path/to/downloaded/$variant');
  }

  @override
  Future<String?> prewarmModels() {
    _checkThrowError();
    return Future.value('Models prewarmed successfully');
  }

  @override
  Future<String?> unloadModels() {
    _checkThrowError();
    return Future.value('Models unloaded successfully');
  }

  @override
  Future<String?> clearState() {
    _checkThrowError();
    return Future.value('State cleared successfully');
  }

  @override
  Future<void> loggingCallback({String? level}) {
    _checkThrowError();
    return Future.value();
  }
}

/// Sets up a mock platform for testing.
///
/// Returns the mock platform instance.
MockFlutterWhisperkitPlatform setUpMockPlatform() {
  final mockPlatform = MockFlutterWhisperkitPlatform();
  FlutterWhisperKitPlatform.instance = mockPlatform;
  return mockPlatform;
}
