import 'package:flutter_whisper_kit/src/models.dart';
import 'package:flutter_whisper_kit/src/services/model_management_service.dart';
import 'package:flutter_whisper_kit/src/services/recording_service.dart';
import 'package:flutter_whisper_kit/src/services/result_api_service.dart';
import 'package:flutter_whisper_kit/src/services/transcription_service.dart';
import 'package:flutter_whisper_kit/src/whisper_kit_error.dart';

/// The main entry point for the Flutter WhisperKit plugin.
///
/// This class provides a high-level API for interacting with WhisperKit,
/// an on-device speech recognition framework for Apple platforms (iOS and macOS).
/// It handles model loading, audio file transcription, and real-time audio
/// recording and transcription.
///
/// The class delegates functionality to specialized service classes:
/// - [ModelManagementService]: Model loading, downloading, and configuration
/// - [RecordingService]: Audio recording and real-time transcription
/// - [TranscriptionService]: File transcription and language detection
/// - [ResultApiService]: Result-based API methods for better error handling
class FlutterWhisperKit {
  FlutterWhisperKit() {
    _modelService = ModelManagementService();
    _recordingService = RecordingService();
    _transcriptionService = TranscriptionService();
    _resultApiService = ResultApiService(
      modelService: _modelService,
      recordingService: _recordingService,
      transcriptionService: _transcriptionService,
    );
  }
  late final ModelManagementService _modelService;
  late final RecordingService _recordingService;
  late final TranscriptionService _transcriptionService;
  late final ResultApiService _resultApiService;

  // ===== Model Management Methods =====

  /// Loads a WhisperKit model.
  ///
  /// Delegates to [ModelManagementService.loadModel].
  /// See [ModelManagementService.loadModel] for detailed documentation.
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
    Function(Progress progress)? onProgress,
  }) async {
    return _modelService.loadModel(
      variant,
      modelRepo: modelRepo,
      redownload: redownload,
      onProgress: onProgress,
    );
  }

  /// Fetches available WhisperKit models from a repository.
  ///
  /// Delegates to [ModelManagementService.fetchAvailableModels].
  /// See [ModelManagementService.fetchAvailableModels] for detailed documentation.
  Future<List<String>> fetchAvailableModels({
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    List<String> matching = const ['*'],
    String? token,
  }) async {
    return _modelService.fetchAvailableModels(
      modelRepo: modelRepo,
      matching: matching,
      token: token,
    );
  }

  /// Downloads a WhisperKit model from a repository.
  ///
  /// Delegates to [ModelManagementService.download].
  /// See [ModelManagementService.download] for detailed documentation.
  Future<String?> download({
    required String variant,
    String? downloadBase,
    bool useBackgroundSession = false,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
    Function(Progress progress)? onProgress,
  }) async {
    return _modelService.download(
      variant: variant,
      downloadBase: downloadBase,
      useBackgroundSession: useBackgroundSession,
      repo: repo,
      token: token,
      onProgress: onProgress,
    );
  }

  /// Returns a list of recommended models for the current device.
  ///
  /// Delegates to [ModelManagementService.recommendedModels].
  /// See [ModelManagementService.recommendedModels] for detailed documentation.
  Future<ModelSupport> recommendedModels() async {
    return _modelService.recommendedModels();
  }

  /// Fetches model support configuration from a remote repository.
  ///
  /// Delegates to [ModelManagementService.fetchModelSupportConfig].
  /// See [ModelManagementService.fetchModelSupportConfig] for detailed documentation.
  Future<ModelSupportConfig> fetchModelSupportConfig() async {
    return _modelService.fetchModelSupportConfig();
  }

  /// Fetches recommended models for the current device from a remote repository.
  ///
  /// Delegates to [ModelManagementService.recommendedRemoteModels].
  /// See [ModelManagementService.recommendedRemoteModels] for detailed documentation.
  Future<ModelSupport> recommendedRemoteModels() async {
    return _modelService.recommendedRemoteModels();
  }

  /// Sets up WhisperKit models with the given parameters.
  ///
  /// Delegates to [ModelManagementService.setupModels].
  /// See [ModelManagementService.setupModels] for detailed documentation.
  Future<String?> setupModels({
    String? model,
    String? downloadBase,
    String? modelRepo,
    String? modelToken,
    String? modelFolder,
    bool download = true,
  }) async {
    return _modelService.setupModels(
      model: model,
      downloadBase: downloadBase,
      modelRepo: modelRepo,
      modelToken: modelToken,
      modelFolder: modelFolder,
      download: download,
    );
  }

  /// Preloads models into memory for faster inference.
  ///
  /// Delegates to [ModelManagementService.prewarmModels].
  /// See [ModelManagementService.prewarmModels] for detailed documentation.
  Future<String?> prewarmModels() async {
    return _modelService.prewarmModels();
  }

  /// Releases model resources when they are no longer needed.
  ///
  /// Delegates to [ModelManagementService.unloadModels].
  /// See [ModelManagementService.unloadModels] for detailed documentation.
  Future<String?> unloadModels() async {
    return _modelService.unloadModels();
  }

  /// Formats model files.
  ///
  /// Delegates to [ModelManagementService.formatModelFiles].
  /// See [ModelManagementService.formatModelFiles] for detailed documentation.
  Future<List<String>> formatModelFiles(List<String> modelFiles) async {
    return _modelService.formatModelFiles(modelFiles);
  }

  /// Stream of model loading progress updates.
  ///
  /// Delegates to [ModelManagementService.modelProgressStream].
  /// See [ModelManagementService.modelProgressStream] for detailed documentation.
  Stream<Progress> get modelProgressStream => _modelService.modelProgressStream;

  // ===== Recording Methods =====

  /// Starts recording audio from the microphone for real-time transcription.
  ///
  /// Delegates to [RecordingService.startRecording].
  /// See [RecordingService.startRecording] for detailed documentation.
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
    return _recordingService.startRecording(
      options: options,
      loop: loop,
    );
  }

  /// Stops recording audio and optionally triggers transcription.
  ///
  /// Delegates to [RecordingService.stopRecording].
  /// See [RecordingService.stopRecording] for detailed documentation.
  Future<String?> stopRecording({bool loop = true}) async {
    return _recordingService.stopRecording(loop: loop);
  }

  /// Resets the transcription state.
  ///
  /// Delegates to [RecordingService.clearState].
  /// See [RecordingService.clearState] for detailed documentation.
  Future<String?> clearState() async {
    return _recordingService.clearState();
  }

  /// Sets the logging callback for WhisperKit.
  ///
  /// Delegates to [RecordingService.loggingCallback].
  /// See [RecordingService.loggingCallback] for detailed documentation.
  Future<void> loggingCallback({String? level}) async {
    return _recordingService.loggingCallback(level: level);
  }

  /// Stream of real-time transcription results.
  ///
  /// Delegates to [RecordingService.transcriptionStream].
  /// See [RecordingService.transcriptionStream] for detailed documentation.
  Stream<TranscriptionResult> get transcriptionStream =>
      _recordingService.transcriptionStream;

  // ===== Transcription Methods =====

  /// Transcribes an audio file at the specified path.
  ///
  /// Delegates to [TranscriptionService.transcribeFromFile].
  /// See [TranscriptionService.transcribeFromFile] for detailed documentation.
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
  }) async {
    return _transcriptionService.transcribeFromFile(
      filePath,
      options: options,
    );
  }

  /// Detects the language of an audio file.
  ///
  /// Delegates to [TranscriptionService.detectLanguage].
  /// See [TranscriptionService.detectLanguage] for detailed documentation.
  Future<LanguageDetectionResult> detectLanguage(String audioPath) async {
    return _transcriptionService.detectLanguage(audioPath);
  }

  /// Returns the name of the device.
  ///
  /// Delegates to [TranscriptionService.deviceName].
  /// See [TranscriptionService.deviceName] for detailed documentation.
  Future<String> deviceName() async {
    return _transcriptionService.deviceName();
  }

  // ===== Result-based API methods =====

  /// Loads a WhisperKit model using the Result pattern.
  ///
  /// Delegates to [ResultApiService.loadModelWithResult].
  /// See [ResultApiService.loadModelWithResult] for detailed documentation.
  Future<Result<String, WhisperKitError>> loadModelWithResult(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
    Function(Progress progress)? onProgress,
  }) async {
    return _resultApiService.loadModelWithResult(
      variant,
      modelRepo: modelRepo,
      redownload: redownload,
      onProgress: onProgress,
    );
  }

  /// Downloads a WhisperKit model using the Result pattern.
  ///
  /// Delegates to [ResultApiService.downloadWithResult].
  /// See [ResultApiService.downloadWithResult] for detailed documentation.
  Future<Result<String, WhisperKitError>> downloadWithResult({
    required String variant,
    String? downloadBase,
    bool useBackgroundSession = false,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
    Function(Progress progress)? onProgress,
  }) async {
    return _resultApiService.downloadWithResult(
      variant: variant,
      downloadBase: downloadBase,
      useBackgroundSession: useBackgroundSession,
      repo: repo,
      token: token,
      onProgress: onProgress,
    );
  }

  /// Fetches available WhisperKit models using the Result pattern.
  ///
  /// Delegates to [ResultApiService.fetchAvailableModelsWithResult].
  /// See [ResultApiService.fetchAvailableModelsWithResult] for detailed documentation.
  Future<Result<List<String>, WhisperKitError>> fetchAvailableModelsWithResult({
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    List<String> matching = const ['*'],
    String? token,
  }) async {
    return _resultApiService.fetchAvailableModelsWithResult(
      modelRepo: modelRepo,
      matching: matching,
      token: token,
    );
  }

  /// Starts audio recording using the Result pattern.
  ///
  /// Delegates to [ResultApiService.startRecordingWithResult].
  /// See [ResultApiService.startRecordingWithResult] for detailed documentation.
  Future<Result<String, WhisperKitError>> startRecordingWithResult({
    bool loop = true,
  }) async {
    return _resultApiService.startRecordingWithResult(loop: loop);
  }

  /// Stops audio recording using the Result pattern.
  ///
  /// Delegates to [ResultApiService.stopRecordingWithResult].
  /// See [ResultApiService.stopRecordingWithResult] for detailed documentation.
  Future<Result<String, WhisperKitError>> stopRecordingWithResult({
    bool loop = true,
  }) async {
    return _resultApiService.stopRecordingWithResult(loop: loop);
  }

  /// Transcribes an audio file using the Result pattern.
  ///
  /// Delegates to [ResultApiService.transcribeFileWithResult].
  /// See [ResultApiService.transcribeFileWithResult] for detailed documentation.
  Future<Result<TranscriptionResult?, WhisperKitError>>
      transcribeFileWithResult(
    String path, {
    DecodingOptions? options,
    Function(Progress progress)? onProgress,
  }) async {
    return _resultApiService.transcribeFileWithResult(
      path,
      options: options,
      onProgress: onProgress,
    );
  }

  /// Detects the language of an audio file using the Result pattern.
  ///
  /// Delegates to [ResultApiService.detectLanguageWithResult].
  /// See [ResultApiService.detectLanguageWithResult] for detailed documentation.
  Future<Result<LanguageDetectionResult?, WhisperKitError>>
      detectLanguageWithResult(
    String audioPath,
  ) async {
    return _resultApiService.detectLanguageWithResult(audioPath);
  }
}
