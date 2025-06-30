import 'dart:async';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_platform_interface.dart';

/// Mock implementation of [FlutterWhisperKitPlatform] for testing.
class MockFlutterWhisperkitPlatform extends FlutterWhisperKitPlatform {
  final StreamController<Progress> _progressController =
      StreamController<Progress>.broadcast();
  final StreamController<TranscriptionResult> _transcriptionController =
      StreamController<TranscriptionResult>.broadcast();

  StreamController<Progress> get progressController => _progressController;
  StreamController<TranscriptionResult> get transcriptionController =>
      _transcriptionController;
  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
  }) async {
    // Emit progress updates when model loading starts
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!_progressController.isClosed) {
        _progressController.add(Progress(
          completedUnitCount: 50,
          totalUnitCount: 100,
          fractionCompleted: 0.5,
          isIndeterminate: false,
        ));
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_progressController.isClosed) {
        _progressController.add(Progress(
          completedUnitCount: 100,
          totalUnitCount: 100,
          fractionCompleted: 1.0,
          isIndeterminate: false,
        ));
      }
    });

    return 'Model loaded';
  }

  /// Stream of model loading progress updates
  @override
  Stream<Progress> get modelProgressStream => _progressController.stream;

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
    if (filePath.isEmpty) {
      throw InvalidArgumentsError(
        message: 'File path cannot be empty',
        code: ErrorCode.invalidParameters,
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
          "noSpeechProb": 0.1,
          "words": [
            {
              "word": "Hello",
              "tokens": [1],
              "start": 0.0,
              "end": 1.0,
              "probability": 0.9
            },
            {
              "word": "world",
              "tokens": [2],
              "start": 1.0,
              "end": 2.0,
              "probability": 0.8
            }
          ]
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
          "noSpeechProb": 0.05,
          "words": [
            {
              "word": "This",
              "tokens": [4],
              "start": 2.0,
              "end": 2.5,
              "probability": 0.9
            },
            {
              "word": "is",
              "tokens": [5],
              "start": 2.5,
              "end": 3.0,
              "probability": 0.8
            },
            {
              "word": "a",
              "tokens": [6],
              "start": 3.0,
              "end": 3.5,
              "probability": 0.7
            },
            {
              "word": "test",
              "tokens": [7],
              "start": 3.5,
              "end": 4.0,
              "probability": 0.9
            }
          ]
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
  }) async {
    // Emit transcription result when recording starts
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_transcriptionController.isClosed) {
        _transcriptionController.add(TranscriptionResult.fromJsonString('''
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
          "language": "en"
        }
        '''));
      }
    });

    return 'Recording started';
  }

  @override
  Future<String?> stopRecording({bool loop = true}) =>
      Future.value('Recording stopped');

  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _transcriptionController.stream;

  @override
  Future<List<String>> fetchAvailableModels({
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    List<String> matching = const ['*'],
    String? token,
  }) {
    return Future.value(['tiny', 'base', 'small', 'medium', 'large']);
  }

  @override
  Future<LanguageDetectionResult> detectLanguage(String audioPath) {
    return Future.value(
      LanguageDetectionResult(
        language: 'en',
        probabilities: {'en': 0.95, 'ja': 0.05},
      ),
    );
  }

  @override
  Future<String> deviceName() {
    return Future.value('Mock Device');
  }

  @override
  Future<ModelSupport> recommendedModels() {
    return Future.value(
      ModelSupport(
        defaultModel: 'base',
        supported: ['tiny', 'base', 'small'],
        disabled: [],
      ),
    );
  }

  @override
  Future<List<String>> formatModelFiles(List<String> modelFiles) {
    return Future.value(modelFiles.map((f) => 'formatted_$f').toList());
  }

  @override
  Future<ModelSupportConfig> fetchModelSupportConfig({
    String? downloadBase,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
  }) {
    return Future.value(
      ModelSupportConfig(
        repoName: repo,
        repoVersion: '1.0.0',
        knownModels: ['tiny', 'base', 'small'],
        defaultSupport: ModelSupport(
          defaultModel: 'base',
          supported: ['tiny', 'base', 'small'],
          disabled: [],
        ),
        deviceSupports: [],
      ),
    );
  }

  @override
  Future<ModelSupport> recommendedRemoteModels({
    String? downloadBase,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
  }) {
    return Future.value(
      ModelSupport(
        defaultModel: 'base',
        supported: ['tiny', 'base', 'small'],
        disabled: [],
      ),
    );
  }

  @override
  Future<String?> setupModels({
    String? model,
    String? downloadBase,
    String? modelRepo,
    String? modelFolder,
    String? modelToken,
    bool download = true,
  }) {
    return Future.value('Models setup successfully');
  }

  @override
  Future<String?> download({
    required String variant,
    String? downloadBase,
    bool useBackgroundSession = false,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
  }) {
    return Future.value('/path/to/downloaded/model');
  }

  @override
  Future<String?> prewarmModels() {
    return Future.value('Models prewarmed');
  }

  @override
  Future<String?> unloadModels() {
    return Future.value('Models unloaded');
  }

  @override
  Future<String?> clearState() {
    return Future.value('State cleared');
  }

  @override
  Future<void> loggingCallback({String? level}) {
    return Future.value();
  }

  /// Emit test progress updates
  void emitProgressUpdate(Progress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  /// Emit test transcription results
  void emitTranscriptionResult(TranscriptionResult result) {
    if (!_transcriptionController.isClosed) {
      _transcriptionController.add(result);
    }
  }

  /// Dispose of stream controllers
  void dispose() {
    _progressController.close();
    _transcriptionController.close();
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
