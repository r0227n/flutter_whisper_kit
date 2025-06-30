import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/models.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Enhanced mock implementation for testing with error code support
class MockFlutterWhisperKitPlatform
    with MockPlatformInterfaceMixin
    implements FlutterWhisperKitPlatform {
  // Test configuration
  bool _shouldThrowOnLoadModel = false;
  bool _shouldThrowOnTranscribeFile = false;
  bool _shouldThrowOnDetectLanguage = false;
  bool _shouldThrowOnStartRecording = false;
  int _errorCode = 1000;

  // Response configuration
  String? _loadModelResponse;
  TranscriptionResult? _transcribeFileResponse;
  LanguageDetectionResult? _detectLanguageResponse;

  // Stream controllers
  final StreamController<Progress> _progressController =
      StreamController<Progress>.broadcast();
  final StreamController<TranscriptionResult> _transcriptionController =
      StreamController<TranscriptionResult>.broadcast();

  // State
  bool _isRecording = false;
  Timer? _transcriptionTimer;

  // Configuration methods
  void setShouldThrowOnLoadModel(bool shouldThrow) {
    _shouldThrowOnLoadModel = shouldThrow;
  }

  void resetMock() {
    _shouldThrowOnLoadModel = false;
    _shouldThrowOnTranscribeFile = false;
    _shouldThrowOnDetectLanguage = false;
    _shouldThrowOnStartRecording = false;
    _errorCode = 1000;
    _loadModelResponse = null;
    _transcribeFileResponse = null;
    _detectLanguageResponse = null;
  }

  void setShouldThrowOnTranscribeFile(bool shouldThrow) {
    _shouldThrowOnTranscribeFile = shouldThrow;
  }

  void setShouldThrowOnDetectLanguage(bool shouldThrow) {
    _shouldThrowOnDetectLanguage = shouldThrow;
  }

  void setShouldThrowOnStartRecording(bool shouldThrow) {
    _shouldThrowOnStartRecording = shouldThrow;
  }

  void setErrorCode(int code) {
    _errorCode = code;
  }

  void setLoadModelResponse(String response) {
    _loadModelResponse = response;
  }

  void setTranscribeFileResponse(TranscriptionResult response) {
    _transcribeFileResponse = response;
  }

  void setDetectLanguageResponse(LanguageDetectionResult response) {
    _detectLanguageResponse = response;
  }

  // Helper to throw platform exception with error code
  void _throwIfConfigured(bool shouldThrow, String method) {
    if (shouldThrow) {
      throw PlatformException(
        code:
            'Domain=WhisperKitError Code=$_errorCode "${ErrorCode.getDescription(_errorCode)}"',
        message: ErrorCode.getDescription(_errorCode),
      );
    }
  }

  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
  }) async {
    _throwIfConfigured(_shouldThrowOnLoadModel, 'loadModel');

    // Simulate progress updates
    Future.microtask(() async {
      for (double progress = 0.0; progress <= 1.0; progress += 0.25) {
        await Future.delayed(Duration(milliseconds: 10));
        if (!_progressController.isClosed) {
          _progressController.add(Progress(
            fractionCompleted: progress,
            totalUnitCount: 100,
            completedUnitCount: (progress * 100).toInt(),
          ));
        }
      }
    });

    // Wait a bit to ensure progress events are emitted
    await Future.delayed(Duration(milliseconds: 100));
    return _loadModelResponse ?? '/path/to/model';
  }

  Future<TranscriptionResult?> transcribeFile(
    String path, {
    DecodingOptions? options,
  }) async {
    _throwIfConfigured(_shouldThrowOnTranscribeFile, 'transcribeFile');
    return _transcribeFileResponse;
  }

  @override
  Future<LanguageDetectionResult> detectLanguage(String audioPath) async {
    _throwIfConfigured(_shouldThrowOnDetectLanguage, 'detectLanguage');
    return _detectLanguageResponse ??
        LanguageDetectionResult(
          language: 'en',
          probabilities: {'en': 0.95, 'ja': 0.03, 'es': 0.02},
        );
  }

  @override
  Future<String?> startRecording({
    DecodingOptions options = const DecodingOptions(),
    bool loop = true,
  }) async {
    _throwIfConfigured(_shouldThrowOnStartRecording, 'startRecording');
    _isRecording = true;

    // Simulate transcription results
    _transcriptionTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (_isRecording) {
        _transcriptionController.add(TranscriptionResult(
          text: 'Test transcription ${DateTime.now().millisecondsSinceEpoch}',
          segments: [],
          language: 'en',
          timings: TranscriptionTimings(
            totalDecodingLoops: 1.0,
            fullPipeline: 0.1,
          ),
        ));
      }
    });

    return 'Recording started';
  }

  @override
  Future<String?> stopRecording({bool loop = true}) async {
    _isRecording = false;
    _transcriptionTimer?.cancel();
    _transcriptionTimer = null;
    return 'Recording stopped';
  }

  @override
  Stream<Progress> get modelProgressStream => _progressController.stream;

  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _transcriptionController.stream;

  @override
  Future<String> deviceName() async {
    return 'MockDevice';
  }

  @override
  Future<ModelSupport> recommendedModels() async {
    return ModelSupport(
      defaultModel: 'tiny',
      supported: ['tiny', 'base', 'small'],
      disabled: [],
    );
  }

  @override
  Future<List<String>> fetchAvailableModels({
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    List<String> matching = const ['*'],
    String? token,
  }) async {
    return ['tiny', 'base', 'small', 'medium', 'large'];
  }

  @override
  Future<ModelSupportConfig> fetchModelSupportConfig({
    String? downloadBase,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
  }) async {
    return ModelSupportConfig(
      repoName: repo,
      repoVersion: '1.0.0',
      deviceSupports: [],
      knownModels: ['tiny', 'base', 'small'],
      defaultSupport: ModelSupport(
        defaultModel: 'tiny',
        supported: ['tiny', 'base', 'small'],
        disabled: [],
      ),
    );
  }

  @override
  Future<ModelSupport> recommendedRemoteModels({
    String? downloadBase,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
  }) async {
    return ModelSupport(
      defaultModel: 'tiny',
      supported: ['tiny', 'base', 'small'],
      disabled: [],
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
  }) async {
    return '/path/to/setup/model';
  }

  @override
  Future<void> loggingCallback({String? level}) async {
    // No-op for mock
  }

  @override
  Future<String?> clearState() async {
    return 'State cleared';
  }

  @override
  Future<String?> download({
    required String variant,
    String? downloadBase,
    bool useBackgroundSession = false,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
  }) async {
    return '/path/to/downloaded/model';
  }

  @override
  Future<List<String>> formatModelFiles(List<String> modelFiles) async {
    return modelFiles;
  }

  @override
  Future<String?> prewarmModels() async {
    return 'Models prewarmed';
  }

  @override
  Future<TranscriptionResult?> transcribeFromFile(
    String filePath, {
    DecodingOptions options = const DecodingOptions(),
    Function(Progress progress)? onProgress,
  }) async {
    _throwIfConfigured(_shouldThrowOnTranscribeFile, 'transcribeFromFile');
    return _transcribeFileResponse;
  }

  @override
  Future<String?> unloadModels() async {
    return 'Models unloaded';
  }

  void dispose() {
    _isRecording = false;
    _transcriptionTimer?.cancel();
    _progressController.close();
    _transcriptionController.close();
  }
}
