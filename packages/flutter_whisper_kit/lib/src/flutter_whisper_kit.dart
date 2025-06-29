import 'dart:async';

import 'package:flutter/services.dart';

import 'models.dart';
import 'platform_specifics/flutter_whisper_kit_platform_interface.dart';
import 'whisper_kit_error.dart';

/// The main entry point for the Flutter WhisperKit plugin.
///
/// This class provides a high-level API for interacting with WhisperKit,
/// an on-device speech recognition framework for Apple platforms (iOS and macOS).
/// It handles model loading, audio file transcription, and real-time audio
/// recording and transcription.
///
/// The class delegates platform-specific implementation details to the
/// [FlutterWhisperKitPlatform] instance, ensuring consistent behavior
/// across different platforms while abstracting away the platform-specific code.
class FlutterWhisperKit {
  /// Helper method to convert typed error to error code
  int _getErrorCodeFromType(WhisperKitErrorType error) {
    return error.errorCode; // Now preserve the original error code
  }

  /// Helper function to handle platform calls with error handling
  Future<T> _handlePlatformCall<T>(Future<T> Function() platformCall) async {
    try {
      return await platformCall();
    } on PlatformException catch (e) {
      throw WhisperKitErrorType.fromPlatformException(e);
    } catch (e) {
      rethrow;
    }
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
  /// - [onProgress]: A callback function that receives download progress updates.
  ///   This can be used to display a progress indicator to the user.
  ///
  /// Returns the path to the model folder if the model is loaded successfully,
  /// or throws a [WhisperKitError] if loading fails.
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
    Function(Progress progress)? onProgress,
  }) async {
    // Subscribe to the progress stream if a callback is provided
    StreamSubscription<Progress>? progressSubscription;

    try {
      if (onProgress != null) {
        progressSubscription = FlutterWhisperKitPlatform
            .instance.modelProgressStream
            .listen((progress) {
          // Convert the Progress object to a simple double for the callback
          onProgress(progress);
        });
      }

      // Delegate to the platform implementation
      return await _handlePlatformCall(
        () => FlutterWhisperKitPlatform.instance.loadModel(
          variant,
          modelRepo: modelRepo,
          redownload: redownload,
        ),
      );
    } finally {
      // Ensure the progress subscription is cancelled to prevent memory leaks
      progressSubscription?.cancel();
    }
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
  /// the transcription text, segments, and timing information, or throws a
  /// [WhisperKitError] if transcription fails.
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
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.transcribeFromFile(
        filePath,
        options: options,
      ),
    );
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
  /// starts successfully, or throws a [WhisperKitError] if starting recording fails.
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
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.startRecording(
        options: options,
        loop: loop,
      ),
    );
  }

  /// Starts audio recording using the Result pattern.
  ///
  /// This is a **Result-based API** that returns a [Result] type instead of 
  /// throwing exceptions, providing better error handling and more explicit 
  /// success/failure states for real-time audio capture.
  ///
  /// ## Parameters
  /// 
  /// - **[loop]** *(optional)*: Recording loop behavior
  ///   - Default: `true`
  ///   - When `true`: Recording automatically restarts after transcription
  ///   - When `false`: Recording stops after each transcription completes
  ///   - Must match the value used in [stopRecordingWithResult]
  ///
  /// ## Return Value
  /// 
  /// Returns a `Future<Result<String, WhisperKitError>>` containing either:
  /// 
  /// - **Success**: A success message indicating recording has started
  /// - **Failure**: A [WhisperKitError] with specific error code and message
  ///
  /// ## Error Codes
  /// 
  /// - **2003**: Generic recording start failure or null result
  /// - **Permission codes**: For microphone access denied
  /// - **Audio session codes**: For audio hardware setup failures
  ///
  /// ## Prerequisites
  /// 
  /// Before calling this method, ensure:
  /// 
  /// 1. **Model is loaded**: Use [loadModelWithResult] first
  /// 2. **Microphone permissions**: Request and verify audio permissions
  /// 3. **Audio session**: Ensure audio session is properly configured
  /// 4. **Hardware availability**: Verify microphone hardware is available
  ///
  /// ## Usage Examples
  /// 
  /// ### Basic Recording
  /// ```dart
  /// // Start continuous recording (loop mode)
  /// final result = await whisperKit.startRecordingWithResult();
  /// result.when(
  ///   success: (message) {
  ///     print('Recording started: $message');
  ///     _updateUI(isRecording: true);
  ///   },
  ///   failure: (error) {
  ///     print('Failed to start recording: ${error.message}');
  ///     _showErrorDialog(error);
  ///   },
  /// );
  /// ```
  /// 
  /// ### Single-Shot Recording
  /// ```dart
  /// // Start recording that stops after transcription
  /// final result = await whisperKit.startRecordingWithResult(loop: false);
  /// result.when(
  ///   success: (message) {
  ///     print('Single recording started: $message');
  ///     _startTimer(); // Auto-stop after timeout
  ///   },
  ///   failure: (error) => _handleRecordingError(error),
  /// );
  /// ```
  /// 
  /// ### Complete Recording Workflow
  /// ```dart
  /// class AudioRecorder {
  ///   bool _isRecording = false;
  ///   
  ///   Future<void> startRecording() async {
  ///     if (_isRecording) return;
  ///     
  ///     // 1. Check permissions
  ///     final hasPermission = await _checkMicrophonePermission();
  ///     if (!hasPermission) {
  ///       _showPermissionDialog();
  ///       return;
  ///     }
  ///     
  ///     // 2. Ensure model is loaded
  ///     final modelResult = await whisperKit.loadModelWithResult('tiny');
  ///     if (modelResult.isFailure) {
  ///       _showError('Please load a model first');
  ///       return;
  ///     }
  ///     
  ///     // 3. Start recording
  ///     final recordResult = await whisperKit.startRecordingWithResult();
  ///     recordResult.when(
  ///       success: (message) {
  ///         _isRecording = true;
  ///         _listenToTranscription();
  ///         _updateUI();
  ///       },
  ///       failure: (error) => _handleError(error),
  ///     );
  ///   }
  ///   
  ///   void _listenToTranscription() {
  ///     whisperKit.transcriptionStream.listen(
  ///       (result) => _onTranscriptionReceived(result),
  ///       onError: (error) => _onTranscriptionError(error),
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// ## Best Practices
  /// 
  /// 1. **Check permissions first** before attempting to record
  /// 2. **Load model before recording** to ensure transcription capability
  /// 3. **Handle concurrent calls** - avoid multiple simultaneous recordings
  /// 4. **Provide user feedback** during loading and error states
  /// 5. **Clean up resources** by stopping recording when appropriate
  /// 6. **Match loop parameter** between start and stop calls
  /// 
  /// ## Related Methods
  /// 
  /// - [stopRecordingWithResult]: Stop audio recording
  /// - [transcriptionStream]: Listen to real-time transcription results
  /// - [loadModelWithResult]: Load model before recording
  /// 
  /// ## See Also
  /// 
  /// - [WhisperKitError]: Error information structure
  /// - [Result]: Result type documentation
  /// - [TranscriptionResult]: Real-time transcription data
  Future<Result<String, WhisperKitError>> startRecordingWithResult({
    bool loop = true,
  }) async {
    try {
      final result = await startRecording(loop: loop);

      if (result == null) {
        return Failure(
          WhisperKitError(
            code: 2003,
            message: 'Failed to start recording: result is null',
          ),
        );
      }

      return Success(result);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } on WhisperKitErrorType catch (e) {
      return Failure(
        WhisperKitError(
          code: _getErrorCodeFromType(e),
          message: e.message,
          details: e.details,
        ),
      );
    } catch (e) {
      return Failure(
        WhisperKitError(
          code: 2003,
          message: 'Failed to start recording: $e',
        ),
      );
    }
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
  /// Throws a [WhisperKitError] if stopping recording fails.
  Future<String?> stopRecording({bool loop = true}) async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.stopRecording(loop: loop),
    );
  }

  /// Stops audio recording using the Result pattern.
  ///
  /// This is a **Result-based API** that returns a [Result] type instead of 
  /// throwing exceptions, providing better error handling and more explicit 
  /// success/failure states for audio recording termination.
  ///
  /// ## Parameters
  /// 
  /// - **[loop]** *(optional)*: Recording loop behavior control
  ///   - Default: `true`
  ///   - When `true`: Recording will restart after transcription completes
  ///   - When `false`: Recording stops completely and triggers final transcription
  ///   - **Must match** the value used in [startRecordingWithResult]
  ///
  /// ## Return Value
  /// 
  /// Returns a `Future<Result<String, WhisperKitError>>` containing either:
  /// 
  /// - **Success**: A success message indicating recording has stopped
  /// - **Failure**: A [WhisperKitError] with specific error code and message
  ///
  /// ## Error Codes
  /// 
  /// - **2004**: Generic recording stop failure or null result
  /// - **Audio session codes**: For audio hardware cleanup failures
  /// - **State codes**: For invalid recording state transitions
  ///
  /// ## Usage Examples
  /// 
  /// ### Stop Continuous Recording
  /// ```dart
  /// // Stop recording but keep transcription going
  /// final result = await whisperKit.stopRecordingWithResult();
  /// result.when(
  ///   success: (message) {
  ///     print('Recording paused: $message');
  ///     // Recording will auto-restart after transcription
  ///   },
  ///   failure: (error) => _handleStopError(error),
  /// );
  /// ```
  /// 
  /// ### Final Stop (Complete Session End)
  /// ```dart
  /// // Stop recording completely
  /// final result = await whisperKit.stopRecordingWithResult(loop: false);
  /// result.when(
  ///   success: (message) {
  ///     print('Recording session ended: $message');
  ///     _updateUI(isRecording: false);
  ///     _cleanupResources();
  ///   },
  ///   failure: (error) => _handleFinalStopError(error),
  /// );
  /// ```
  /// 
  /// ### Voice Memo Implementation
  /// ```dart
  /// class VoiceMemo {
  ///   bool _isRecording = false;
  ///   final List<String> _transcripts = [];
  ///   
  ///   Future<void> stopMemo() async {
  ///     if (!_isRecording) return;
  ///     
  ///     final stopResult = await whisperKit.stopRecordingWithResult(loop: false);
  ///     stopResult.when(
  ///       success: (message) {
  ///         _isRecording = false;
  ///         _saveMemo(_transcripts.join(' '));
  ///       },
  ///       failure: (error) => _handleStopError(error),
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// ## Best Practices
  /// 
  /// 1. **Match loop parameters** between start and stop calls
  /// 2. **Use `loop: false`** for final session termination
  /// 3. **Clean up resources** after final stop
  /// 4. **Handle both success and failure** cases appropriately
  /// 
  /// ## Related Methods
  /// 
  /// - [startRecordingWithResult]: Start audio recording
  /// - [transcriptionStream]: Listen to transcription results
  /// 
  /// ## See Also
  /// 
  /// - [WhisperKitError]: Error information structure
  /// - [Result]: Result type documentation
  Future<Result<String, WhisperKitError>> stopRecordingWithResult({
    bool loop = true,
  }) async {
    try {
      final result = await stopRecording(loop: loop);

      if (result == null) {
        return Failure(
          WhisperKitError(
            code: 2004,
            message: 'Failed to stop recording: result is null',
          ),
        );
      }

      return Success(result);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } on WhisperKitErrorType catch (e) {
      return Failure(
        WhisperKitError(
          code: _getErrorCodeFromType(e),
          message: e.message,
          details: e.details,
        ),
      );
    } catch (e) {
      return Failure(
        WhisperKitError(
          code: 2004,
          message: 'Failed to stop recording: $e',
        ),
      );
    }
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
  /// Example usage:
  /// ```dart
  /// final subscription = flutterWhisperkit.transcriptionStream.listen((result) {
  ///   setState(() {
  ///     _transcriptionText = result.text;
  ///     _language = result.language;
  ///     _segments = result.segments;
  ///   });
  /// });
  ///
  /// // Don't forget to cancel the subscription when done
  /// subscription.cancel();
  /// ```
  Stream<TranscriptionResult> get transcriptionStream =>
      FlutterWhisperKitPlatform.instance.transcriptionStream;

  /// Stream of model loading progress updates.
  ///
  /// This stream emits [Progress] objects containing information about the
  /// ongoing model loading task, including completed units, total units,
  /// and the progress fraction. This allows clients to display progress
  /// indicators during model download and initialization.
  ///
  /// The progress updates are particularly useful for large models that
  /// may take some time to download, allowing the application to provide
  /// feedback to the user about the download status.
  Stream<Progress> get modelProgressStream =>
      FlutterWhisperKitPlatform.instance.modelProgressStream;

  /// Fetches available WhisperKit models from a repository.
  ///
  /// - [modelRepo]: The repository to fetch models from (default: "argmaxinc/whisperkit-coreml").
  /// - [matching]: Optional list of glob patterns to filter models by.
  /// - [token]: Optional access token for private repositories.
  ///
  /// Returns a list of available model names.
  ///
  /// Example:
  /// ```dart
  /// final models = await flutterWhisperKit.fetchAvailableModels();
  /// print('Available models: $models');
  /// ```
  Future<List<String>> fetchAvailableModels({
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    List<String> matching = const ['*'],
    String? token,
  }) async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.fetchAvailableModels(
        modelRepo: modelRepo,
        matching: matching,
        token: token,
      ),
    );
  }

  /// Fetches available WhisperKit models using the Result pattern.
  ///
  /// This is a new API that returns a Result type instead of throwing exceptions,
  /// providing better error handling and more explicit success/failure states.
  ///
  /// Parameters:
  /// - [modelRepo]: The repository to fetch models from (default: "argmaxinc/whisperkit-coreml").
  /// - [matching]: Optional list of glob patterns to filter models by (default: ['*']).
  /// - [token]: Optional access token for private repositories.
  ///
  /// Returns a [Result] containing either:
  /// - Success: A list of available model names
  /// - Failure: A [WhisperKitError] describing what went wrong
  ///
  /// Example:
  /// ```dart
  /// final result = await whisperKit.fetchAvailableModelsWithResult();
  /// result.when(
  ///   success: (models) => print('Available models: $models'),
  ///   failure: (error) => print('Failed to fetch models: ${error.message}'),
  /// );
  /// ```
  Future<Result<List<String>, WhisperKitError>> fetchAvailableModelsWithResult({
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    List<String> matching = const ['*'],
    String? token,
  }) async {
    try {
      final models = await fetchAvailableModels(
        modelRepo: modelRepo,
        matching: matching,
        token: token,
      );

      return Success(models);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } on WhisperKitErrorType catch (e) {
      return Failure(
        WhisperKitError(
          code: _getErrorCodeFromType(e),
          message: e.message,
          details: e.details,
        ),
      );
    } catch (e) {
      return Failure(
        WhisperKitError(
          code: 1001,
          message: 'Failed to fetch available models: $e',
        ),
      );
    }
  }

  /// Returns the name of the device.
  ///
  /// This method returns the name of the device running the application.
  /// It uses the `deviceName` method from the platform interface to get
  /// the device name.
  ///
  /// Returns the name of the device.
  ///
  /// Example:
  /// ```dart
  /// final deviceName = await flutterWhisperKit.deviceName();
  /// print('Device name: $deviceName');
  /// ```
  Future<String> deviceName() async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.deviceName(),
    );
  }

  /// Returns a list of recommended models for the current device.
  ///
  /// This method returns a list of model variants that are recommended for
  /// the current device based on its hardware capabilities and WhisperKit's
  /// model compatibility matrix.
  ///
  /// Returns a [ModelSupport] object containing the default model, supported models, and disabled models.
  ///
  /// Example:
  /// ```dart
  /// final modelSupport = await flutterWhisperKit.recommendedModels();
  /// print('Default model: ${modelSupport.defaultModel}');
  /// print('Supported models: ${modelSupport.supported}');
  /// print('Disabled models: ${modelSupport.disabled}');
  /// ```
  Future<ModelSupport> recommendedModels() async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.recommendedModels(),
    );
  }

  /// Detects the language of an audio file.
  ///
  /// This method analyzes the audio content and determines the most likely
  /// language being spoken, along with confidence scores for various languages.
  ///
  /// Returns a [Future] that completes with a [LanguageDetectionResult] containing
  /// the detected language code and a map of language probabilities.
  ///
  /// Example:
  /// ```dart
  /// final result = await flutterWhisperKit.detectLanguage(filePath);
  /// print('Detected language: ${result.language}');
  /// print('Language probabilities: ${result.probabilities}');
  /// ```
  Future<LanguageDetectionResult> detectLanguage(String audioPath) async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.detectLanguage(audioPath),
    );
  }

  /// Formats model files.
  ///
  /// This method formats model files for consistent handling across the plugin.
  ///
  /// Parameters:
  /// - [modelFiles]: A list of model file names to format.
  ///
  /// Returns a list of formatted model file names.
  ///
  /// Example:
  /// ```dart
  /// final formattedModelFiles = await flutterWhisperKit.formatModelFiles(modelFiles);
  /// print('Formatted model files: $formattedModelFiles');
  /// ```
  Future<List<String>> formatModelFiles(List<String> modelFiles) async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.formatModelFiles(modelFiles),
    );
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
  /// Example:
  /// ```dart
  /// final modelSupportConfig = await flutterWhisperKit.fetchModelSupportConfig();
  /// print('Model support config: $modelSupportConfig');
  /// ```
  Future<ModelSupportConfig> fetchModelSupportConfig() async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.fetchModelSupportConfig(),
    );
  }

  /// Fetches recommended models for the current device from a remote repository.
  ///
  /// This method retrieves model support information specifically tailored for
  /// the current device from a remote repository.
  ///
  /// Returns a [Future] that completes with a [ModelSupport] object containing
  /// information about supported models for the current device.
  ///
  /// Example:
  /// ```dart
  /// final modelSupport = await flutterWhisperKit.recommendedRemoteModels();
  /// print('Recommended models: $modelSupport');
  /// ```
  Future<ModelSupport> recommendedRemoteModels() async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.recommendedRemoteModels(),
    );
  }

  /// Sets up WhisperKit models with the given parameters.
  ///
  /// This method initializes the WhisperKit framework with the specified configuration.
  /// It either uses a local model folder if provided or downloads the model.
  ///
  /// Parameters:
  /// - [model]: The model variant to use.
  /// - [downloadBase]: The base URL for downloads.
  /// - [modelRepo]: The repository to download the model from.
  /// - [modelToken]: An access token for the repository.
  /// - [modelFolder]: A local folder containing the model files.
  /// - [download]: Whether to download the model if not available locally.
  ///
  /// Returns a [Future] that completes with a success message if the models are set up successfully,
  /// or throws a [WhisperKitError] if setup fails.
  Future<String?> setupModels({
    String? model,
    String? downloadBase,
    String? modelRepo,
    String? modelToken,
    String? modelFolder,
    bool download = true,
  }) async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.setupModels(
        model: model,
        downloadBase: downloadBase,
        modelRepo: modelRepo,
        modelToken: modelToken,
        modelFolder: modelFolder,
        download: download,
      ),
    );
  }

  /// Downloads a WhisperKit model from a repository.
  ///
  /// This method downloads a model variant from the specified repository
  /// and tracks the progress through the [modelProgressStream].
  ///
  /// Parameters:
  /// - [variant]: The model variant to download.
  /// - [downloadBase]: The base URL for downloads.
  /// - [useBackgroundSession]: Whether to use a background session for the download.
  /// - [repo]: The repository to download from.
  /// - [token]: An access token for the repository.
  /// - [onProgress]: A callback function that receives download progress updates.
  ///
  /// Returns a [Future] that completes with the path to the downloaded model,
  /// or throws a [WhisperKitError] if download fails.
  Future<String?> download({
    required String variant,
    String? downloadBase,
    bool useBackgroundSession = false,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
    Function(Progress progress)? onProgress,
  }) async {
    // Subscribe to the progress stream if a callback is provided
    StreamSubscription<Progress>? progressSubscription;

    try {
      if (onProgress != null) {
        progressSubscription = FlutterWhisperKitPlatform
            .instance.modelProgressStream
            .listen((progress) {
          onProgress(progress);
        });
      }

      return await _handlePlatformCall(
        () => FlutterWhisperKitPlatform.instance.download(
          variant: variant,
          downloadBase: downloadBase,
          useBackgroundSession: useBackgroundSession,
          repo: repo,
          token: token,
        ),
      );
    } finally {
      // Ensure the progress subscription is cancelled to prevent memory leaks
      progressSubscription?.cancel();
    }
  }

  /// Downloads a WhisperKit model using the Result pattern.
  ///
  /// This is a new API that returns a Result type instead of throwing exceptions,
  /// providing better error handling and more explicit success/failure states.
  ///
  /// Parameters:
  /// - [variant]: The model variant to download (required).
  /// - [downloadBase]: The base URL for downloads.
  /// - [useBackgroundSession]: Whether to use a background session for the download.
  /// - [repo]: The repository to download from (default: 'argmaxinc/whisperkit-coreml').
  /// - [token]: An access token for the repository.
  /// - [onProgress]: A callback function that receives download progress updates.
  ///
  /// Returns a [Result] containing either:
  /// - Success: The path to the downloaded model
  /// - Failure: A [WhisperKitError] describing what went wrong
  ///
  /// Example:
  /// ```dart
  /// final result = await whisperKit.downloadWithResult(
  ///   variant: 'tiny',
  ///   onProgress: (progress) => print('Progress: ${progress.fractionCompleted}'),
  /// );
  /// result.when(
  ///   success: (modelPath) => print('Model downloaded to: $modelPath'),
  ///   failure: (error) => print('Download failed: ${error.message}'),
  /// );
  /// ```
  Future<Result<String, WhisperKitError>> downloadWithResult({
    required String variant,
    String? downloadBase,
    bool useBackgroundSession = false,
    String repo = 'argmaxinc/whisperkit-coreml',
    String? token,
    Function(Progress progress)? onProgress,
  }) async {
    try {
      final modelPath = await download(
        variant: variant,
        downloadBase: downloadBase,
        useBackgroundSession: useBackgroundSession,
        repo: repo,
        token: token,
        onProgress: onProgress,
      );

      if (modelPath == null) {
        return Failure(
          WhisperKitError(
            code: 1000,
            message: 'Download failed: model path is null',
          ),
        );
      }

      return Success(modelPath);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } on WhisperKitErrorType catch (e) {
      return Failure(
        WhisperKitError(
          code: _getErrorCodeFromType(e),
          message: e.message,
          details: e.details,
        ),
      );
    } catch (e) {
      return Failure(
        WhisperKitError(
          code: 1000,
          message: 'Download failed: $e',
        ),
      );
    }
  }

  /// Preloads models into memory for faster inference.
  ///
  /// This method prepares the models for use by loading them into memory
  /// but does not perform any inference. It is useful for reducing the
  /// latency of the first transcription.
  ///
  /// Returns a [Future] that completes with a success message if the models are prewarmed successfully,
  /// or throws a [WhisperKitError] if prewarming fails.
  Future<String?> prewarmModels() async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.prewarmModels(),
    );
  }

  /// Releases model resources when they are no longer needed.
  ///
  /// This method unloads the models from memory to free up resources.
  /// It should be called when the models are no longer needed.
  ///
  /// Returns a [Future] that completes with a success message if the models are unloaded successfully,
  /// or throws a [WhisperKitError] if unloading fails.
  Future<String?> unloadModels() async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.unloadModels(),
    );
  }

  /// Resets the transcription state.
  ///
  /// This method stops recording and resets the transcription timings.
  /// It should be called when starting a new transcription session.
  ///
  /// Returns a [Future] that completes with a success message if the state is cleared successfully,
  /// or throws a [WhisperKitError] if clearing fails.
  Future<String?> clearState() async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.clearState(),
    );
  }

  /// Sets the logging callback for WhisperKit.
  ///
  /// This method configures a callback function for tracking progress and debugging.
  /// The callback receives log messages with the specified level.
  ///
  /// Parameters:
  /// - [level]: The logging level (e.g., "debug", "info", "warning", "error").
  ///
  /// Throws a [WhisperKitError] if setting the logging callback fails.
  Future<void> loggingCallback({String? level}) async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.loggingCallback(level: level),
    );
  }

  // ===== Result-based API methods (new API design) =====

  /// Loads a WhisperKit model using the Result pattern.
  ///
  /// This is a new API that returns a Result type instead of throwing exceptions,
  /// providing better error handling and more explicit success/failure states.
  ///
  /// Parameters:
  /// - [variant]: The model variant to load.
  /// - [modelRepo]: The repository to download the model from.
  /// - [redownload]: Whether to force redownload the model.
  /// - [onProgress]: A callback function for download progress updates.
  ///
  /// Returns a [Result] containing either:
  /// - Success: The path to the loaded model folder
  /// - Failure: A [WhisperKitError] describing what went wrong
  ///
  /// Example:
  /// ```dart
  /// final result = await whisperKit.loadModelWithResult('tiny-en');
  /// result.when(
  ///   success: (modelPath) => print('Model loaded at: $modelPath'),
  ///   failure: (error) => print('Failed to load model: $error'),
  /// );
  /// ```
  Future<Result<String, WhisperKitError>> loadModelWithResult(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
    Function(Progress progress)? onProgress,
  }) async {
    try {
      final modelPath = await loadModel(
        variant,
        modelRepo: modelRepo,
        redownload: redownload,
        onProgress: onProgress,
      );

      if (modelPath == null) {
        return Failure(
          WhisperKitError(
            code: 1001,
            message: 'Model loading returned null',
          ),
        );
      }

      return Success(modelPath);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } on WhisperKitErrorType catch (e) {
      // Convert typed error to WhisperKitError for Result API
      return Failure(
        WhisperKitError(
          code: _getErrorCodeFromType(e),
          message: e.message,
          details: e.details,
        ),
      );
    } catch (e) {
      return Failure(
        WhisperKitError(
          code: 1000,
          message: 'Unexpected error: $e',
        ),
      );
    }
  }

  /// Transcribes an audio file using the Result pattern.
  ///
  /// This method provides a safer alternative to the throwing version,
  /// returning a Result that explicitly represents success or failure.
  ///
  /// Parameters:
  /// - [path]: The path to the audio file to transcribe.
  /// - [options]: Optional decoding options for transcription.
  /// - [onProgress]: Optional callback for transcription progress.
  ///
  /// Returns a [Result] containing either:
  /// - Success: A [TranscriptionResult] with the transcribed text
  /// - Failure: A [WhisperKitError] describing what went wrong
  Future<Result<TranscriptionResult?, WhisperKitError>>
      transcribeFileWithResult(
    String path, {
    DecodingOptions? options,
    Function(Progress progress)? onProgress,
  }) async {
    try {
      final result = await transcribeFromFile(
        path,
        options: options ?? const DecodingOptions(),
      );
      return Success(result);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } on WhisperKitErrorType catch (e) {
      // Convert typed error to WhisperKitError for Result API
      return Failure(
        WhisperKitError(
          code: _getErrorCodeFromType(e),
          message: e.message,
          details: e.details,
        ),
      );
    } catch (e) {
      return Failure(
        WhisperKitError(
          code: 2001,
          message: 'Transcription failed: $e',
        ),
      );
    }
  }

  /// Detects the language of an audio file using the Result pattern.
  ///
  /// Returns a [Result] containing either:
  /// - Success: A [LanguageDetectionResult] with detected language info
  /// - Failure: A [WhisperKitError] describing what went wrong
  Future<Result<LanguageDetectionResult?, WhisperKitError>>
      detectLanguageWithResult(
    String audioPath,
  ) async {
    try {
      final result = await detectLanguage(audioPath);
      return Success(result);
    } on WhisperKitError catch (e) {
      return Failure(e);
    } on WhisperKitErrorType catch (e) {
      // Convert typed error to WhisperKitError for Result API
      return Failure(
        WhisperKitError(
          code: _getErrorCodeFromType(e),
          message: e.message,
          details: e.details,
        ),
      );
    } catch (e) {
      return Failure(
        WhisperKitError(
          code: 2002,
          message: 'Language detection failed: $e',
        ),
      );
    }
  }
}
