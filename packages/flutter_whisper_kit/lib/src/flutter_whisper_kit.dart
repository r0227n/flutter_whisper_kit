import 'dart:async';

import 'package:flutter/services.dart';

import 'models.dart';
import 'whisper_kit_error.dart';
import 'platform_specifics/flutter_whisper_kit_platform_interface.dart';

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
            .instance
            .modelProgressStream
            .listen((progress) {
              // Convert the Progress object to a simple double for the callback
              onProgress(progress);
            });
      }

      // Delegate to the platform implementation
      return await FlutterWhisperKitPlatform.instance.loadModel(
        variant,
        modelRepo: modelRepo,
        redownload: redownload,
      );
    } on PlatformException catch (e) {
      // Convert platform exceptions to WhisperKitError for better error handling
      throw WhisperKitError.fromPlatformException(e);
    } catch (e) {
      // Rethrow other exceptions
      rethrow;
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
    try {
      // Delegate to the platform implementation
      return await FlutterWhisperKitPlatform.instance.transcribeFromFile(
        filePath,
        options: options,
      );
    } on PlatformException catch (e) {
      // Convert platform exceptions to WhisperKitError for better error handling
      throw WhisperKitError.fromPlatformException(e);
    } catch (e) {
      // Rethrow other exceptions
      rethrow;
    }
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
    try {
      // Delegate to the platform implementation
      return await FlutterWhisperKitPlatform.instance.startRecording(
        options: options,
        loop: loop,
      );
    } on PlatformException catch (e) {
      // Convert platform exceptions to WhisperKitError for better error handling
      throw WhisperKitError.fromPlatformException(e);
    } catch (e) {
      // Rethrow other exceptions
      rethrow;
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
    try {
      // Delegate to the platform implementation
      return await FlutterWhisperKitPlatform.instance.stopRecording(loop: loop);
    } on PlatformException catch (e) {
      // Convert platform exceptions to WhisperKitError for better error handling
      throw WhisperKitError.fromPlatformException(e);
    } catch (e) {
      // Rethrow other exceptions
      rethrow;
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
    try {
      return await FlutterWhisperKitPlatform.instance.fetchAvailableModels(
        modelRepo: modelRepo,
        matching: matching,
        token: token,
      );
    } on PlatformException catch (e) {
      throw WhisperKitError.fromPlatformException(e);
    } catch (e) {
      rethrow;
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
    return await FlutterWhisperKitPlatform.instance.deviceName();
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
    return await FlutterWhisperKitPlatform.instance.recommendedModels();
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
    return await FlutterWhisperKitPlatform.instance.detectLanguage(audioPath);
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
    return await FlutterWhisperKitPlatform.instance.formatModelFiles(
      modelFiles,
    );
  }
}
