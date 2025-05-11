import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_whisper_kit_method_channel.dart';
import '../models.dart';

/// The platform interface that all implementations of flutter_whisper_kit must implement.
///
/// Platform implementations should extend this class rather than implement it
/// as flutter_whisper_kit considers all implementations that implement this
/// interface to be conforming implementations.
///
/// This abstract class defines the API contract for the WhisperKit plugin
/// across all supported platforms, ensuring consistent behavior regardless
/// of the underlying platform implementation.
abstract class FlutterWhisperKitPlatform extends PlatformInterface {
  /// Constructs a FlutterWhisperKitPlatform.
  ///
  /// This constructor is protected and should only be used by subclasses.
  /// It initializes the platform interface with a token for verification.
  FlutterWhisperKitPlatform() : super(token: _token);

  /// The token used to verify that implementations extend rather than implement this class.
  static final Object _token = Object();

  /// The default implementation instance of the platform interface.
  static FlutterWhisperKitPlatform _instance = MethodChannelFlutterWhisperKit();

  /// The default instance of [FlutterWhisperKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWhisperKit], which uses method channels
  /// to communicate with the native platform code.
  ///
  /// This getter provides access to the current platform implementation,
  /// allowing the plugin to delegate method calls to the appropriate
  /// platform-specific code.
  static FlutterWhisperKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWhisperKitPlatform] when
  /// they register themselves.
  ///
  /// This setter allows platform-specific implementations to register
  /// themselves as the current implementation. It verifies that the provided
  /// instance extends this class using the token system.
  static set instance(FlutterWhisperKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Loads a WhisperKit model.
  ///
  /// Downloads and initializes a WhisperKit model for speech recognition.
  /// This method handles both downloading the model if it doesn't exist
  /// locally and loading it into memory for use.
  ///
  /// Parameters:
  /// - [variant]: The model variant to load (e.g., 'tiny-en', 'base', 'small', 'medium', 'large-v2').
  ///   Different variants offer different trade-offs between accuracy and performance.
  /// - [modelRepo]: The repository to download the model from (default: 'argmaxinc/whisperkit-coreml').
  ///   This is the Hugging Face repository where the model files are hosted.
  /// - [redownload]: Whether to force redownload the model even if it exists locally.
  ///   Set to true to ensure you have the latest version of the model.
  ///
  /// Returns the path to the model folder if the model is loaded successfully,
  /// or throws a [WhisperKitError] if loading fails.
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
  }) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  /// Transcribes an audio file at the specified path.
  ///
  /// Processes an audio file and generates a text transcription using the
  /// loaded WhisperKit model. This method handles the entire transcription
  /// process, including audio loading, processing, and text generation.
  ///
  /// Parameters:
  /// - [filePath]: The path to the audio file to transcribe.
  ///   This should be a valid path to an audio file in a supported format.
  /// - [options]: Optional decoding options to customize the transcription process.
  ///   These options control various aspects of the transcription, such as
  ///   language, task type, temperature, and more.
  ///
  /// Returns a [Future] that completes with a [TranscriptionResult] containing
  /// the transcription text, segments, and timing information.
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this method.
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
    throw UnimplementedError('transcribeFromFile() has not been implemented.');
  }

  /// Starts recording audio from the microphone for real-time transcription.
  ///
  /// Begins capturing audio from the device's microphone and optionally
  /// starts real-time transcription. This method handles microphone permission
  /// requests, audio capture configuration, and transcription setup.
  ///
  /// Parameters:
  /// - [options]: Optional decoding options to customize the transcription process.
  ///   These options control various aspects of the transcription, such as
  ///   language, task type, temperature, and more.
  /// - [loop]: If true, continuously transcribes audio in a loop until stopped.
  ///   If false, transcription happens when stopRecording is called.
  ///
  /// Returns a [Future] that completes with a success message if recording
  /// starts successfully, or an error message if starting recording fails.
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this method.
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
    throw UnimplementedError('startRecording() has not been implemented.');
  }

  /// Stops recording audio and optionally triggers transcription.
  ///
  /// Stops the audio capture from the device's microphone and, depending on
  /// the [loop] parameter, may trigger transcription of the recorded audio.
  ///
  /// Parameters:
  /// - [loop]: Must match the loop parameter used when starting recording.
  ///   This ensures consistent behavior between starting and stopping recording.
  ///
  /// Returns a [Future] that completes with a success message when recording
  /// is stopped. If [loop] is false, also triggers transcription of the recorded audio.
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this method.
  Future<String?> stopRecording({bool loop = true}) {
    throw UnimplementedError('stopRecording() has not been implemented.');
  }

  /// Stream of real-time transcription results.
  ///
  /// This stream emits [TranscriptionResult] objects containing the full
  /// transcription data as it becomes available during real-time transcription.
  /// The stream will emit an empty result when recording stops.
  ///
  /// This getter provides access to the transcription stream, allowing clients
  /// to listen for and react to transcription updates in real-time.
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this getter.
  Stream<TranscriptionResult> get transcriptionStream {
    throw UnimplementedError('transcriptionStream has not been implemented.');
  }

  /// Stream of model loading progress updates.
  ///
  /// This stream emits [Progress] objects containing information about the
  /// ongoing model loading task, including completed units, total units,
  /// and the progress fraction. This allows clients to display progress
  /// indicators during model download and initialization.
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this getter.
  Stream<Progress> get modelProgressStream {
    throw UnimplementedError('modelProgressStream has not been implemented.');
  }

  /// Fetches available WhisperKit models from a repository.
  ///
  /// - [modelRepo]: The repository to fetch models from (default: "argmaxinc/whisperkit-coreml").
  /// - [matching]: Optional list of glob patterns to filter models by.
  /// - [token]: Optional access token for private repositories.
  ///
  /// Returns a list of available model names.
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this method.
  Future<List<String>> fetchAvailableModels({
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    List<String> matching = const ['*'],
    String? token,
  }) {
    throw UnimplementedError(
      'fetchAvailableModels() has not been implemented.',
    );
  }

  /// Detects the language of an audio file.
  ///
  /// This method analyzes the audio content and determines the most likely
  /// language being spoken, along with confidence scores for various languages.
  ///
  /// Parameters:
  /// - [audioPath]: The path to the audio file to analyze.
  ///   This should be a valid path to an audio file in a supported format.
  ///
  /// Returns a [Future] that completes with a [LanguageDetectionResult] containing
  /// the detected language code and a map of language probabilities.
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this method.
  Future<LanguageDetectionResult> detectLanguage(String audioPath) {
    throw UnimplementedError('detectLanguage() has not been implemented.');
  }

  /// Gets the current device name.
  ///
  /// Returns the name of the current device as recognized by WhisperKit.
  /// This is useful for determining which models are compatible with the device.
  ///
  /// Returns a [Future] that completes with the device name as a [String].
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this method.
  Future<String> deviceName() {
    throw UnimplementedError('deviceName() has not been implemented.');
  }

  /// Gets the recommended models for the current device.
  ///
  /// Returns information about which models are supported on the current device,
  /// including the default recommended model and any disabled models.
  ///
  /// Returns a [Future] that completes with a [ModelSupport] object.
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this method.
  Future<ModelSupport> recommendedModels() {
    throw UnimplementedError('recommendedModels() has not been implemented.');
  }

  /// Formats model file names.
  ///
  /// This method takes a list of model file names and returns a list of
  /// formatted model file names. It is used to standardize model file names
  /// for consistent handling across the plugin.
  ///
  /// Parameters:
  /// - [modelFiles]: A list of model file names to format.
  ///
  /// Returns a [Future] that completes with a list of formatted model file names.
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this method.
  Future<List<String>> formatModelFiles(List<String> modelFiles) {
    throw UnimplementedError('formatModelFiles() has not been implemented.');
  }

  /// Fetches model support configuration from a remote repository.
  ///
  /// This method retrieves a configuration file from the specified repository
  /// that contains information about which models are supported on different devices.
  ///
  /// Parameters:
  /// - [repo]: The repository name (default: "argmaxinc/whisperkit-coreml").
  /// - [downloadBase]: The base URL for downloads (optional).
  /// - [token]: An access token for the repository (optional).
  ///
  /// Returns a [Future] that completes with a [ModelSupportConfig] object containing
  /// information about supported models for different devices.
  ///
  /// Throws an [UnimplementedError] if the subclass does not override this method.
  Future<ModelSupportConfig> fetchModelSupportConfig({
    String repo = 'argmaxinc/whisperkit-coreml',
    String? downloadBase,
    String? token,
  }) {
    throw UnimplementedError(
      'fetchModelSupportConfig() has not been implemented.',
    );
  }
}
