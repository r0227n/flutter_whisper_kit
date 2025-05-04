import 'dart:async';

import '../flutter_whisperkit.dart';

/// A class for loading and managing WhisperKit models.
///
/// This class provides a convenient way to load WhisperKit models with
/// progress tracking. It handles the communication with the native WhisperKit
/// framework and manages the model download and initialization process.
class WhisperKitModelLoader {
  /// Creates a new WhisperKitModelLoader instance.
  ///
  /// Initializes the loader with a new FlutterWhisperKit instance that will
  /// be used for all model loading operations.
  WhisperKitModelLoader() : _whisperkit = FlutterWhisperKit();

  /// The internal FlutterWhisperKit instance used for model operations.
  final FlutterWhisperKit _whisperkit;

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
  /// - [modelDownloadPath]: Custom path where the model should be downloaded.
  ///   If not provided, the model will be stored in the default location.
  ///
  /// Returns a [Future] that completes with a success message when the model
  /// is loaded successfully, or an error message if loading fails.
  Future<String?> loadModel({
    required String variant,
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    bool redownload = false,
    Function(double progress)? onProgress,
    String? modelDownloadPath,
  }) async {
    // Initialize the model loading
    final result = _whisperkit.loadModel(
      variant,
      modelRepo: modelRepo,
      redownload: redownload,
      modelDownloadPath: modelDownloadPath,
    );

    // Subscribe to the progress stream if a callback is provided
    StreamSubscription<Progress>? progressSubscription;
    if (onProgress != null) {
      progressSubscription = _whisperkit.modelProgressStream.listen((progress) {
        // Convert the Progress object to a simple double for the callback
        onProgress(progress.fractionCompleted);
      });
    }

    try {
      // Wait for the model loading to complete and return the result
      return await result;
    } finally {
      // Ensure the progress subscription is cancelled to prevent memory leaks
      progressSubscription?.cancel();
    }
  }
}
