import 'dart:async';

import 'package:flutter/services.dart';

import '../models.dart';
import '../platform_specifics/flutter_whisper_kit_platform_interface.dart';
import '../whisper_kit_error.dart';

/// Service class for managing WhisperKit models.
///
/// This class handles all model-related operations including:
/// - Loading models from repositories
/// - Downloading model files
/// - Fetching available models
/// - Managing model metadata and configuration
class ModelManagementService {
  /// Helper function to handle platform calls with error handling
  Future<T> _handlePlatformCall<T>(Future<T> Function() platformCall) async {
    try {
      return await platformCall();
    } on PlatformException catch (e) {
      throw WhisperKitError.fromPlatformException(e);
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
  /// final models = await modelService.fetchAvailableModels();
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

  /// Returns a list of recommended models for the current device.
  ///
  /// This method returns a list of model variants that are recommended for
  /// the current device based on its hardware capabilities and WhisperKit's
  /// model compatibility matrix.
  ///
  /// Returns a [ModelSupport] object containing the default model, supported models, and disabled models.
  Future<ModelSupport> recommendedModels() async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.recommendedModels(),
    );
  }

  /// Fetches model support configuration from a remote repository.
  ///
  /// This method retrieves a configuration file from the specified repository
  /// that contains information about which models are supported on different devices.
  ///
  /// Returns a [Future] that completes with a [ModelSupportConfig] object containing
  /// information about supported models for different devices.
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

  /// Formats model files.
  ///
  /// This method formats model files for consistent handling across the plugin.
  ///
  /// Parameters:
  /// - [modelFiles]: A list of model file names to format.
  ///
  /// Returns a list of formatted model file names.
  Future<List<String>> formatModelFiles(List<String> modelFiles) async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.formatModelFiles(modelFiles),
    );
  }

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
}
