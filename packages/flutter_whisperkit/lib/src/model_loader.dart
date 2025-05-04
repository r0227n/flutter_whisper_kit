import 'dart:async';

import '../flutter_whisperkit.dart';

/// A class for loading and managing WhisperKit models.
class WhisperKitModelLoader {
  /// Creates a new WhisperKitModelLoader instance.
  WhisperKitModelLoader() : _whisperkit = FlutterWhisperkit();

  final FlutterWhisperkit _whisperkit;

  /// Loads a WhisperKit model.
  ///
  /// [variant] - The model variant to load (e.g., 'tiny-en', 'base', 'small', 'medium', 'large-v2').
  /// [modelRepo] - The repository to download the model from (default: 'argmaxinc/whisperkit-coreml').
  /// [redownload] - Whether to force redownload the model even if it exists locally.
  /// [onProgress] - A callback function that receives download progress updates.
  /// [storageLocation] - Where to store the model (default: ModelStorageLocation.packageDirectory).
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
        onProgress(progress.fractionCompleted);
      });
    }

    try {
      return await result;
    } finally {
      progressSubscription?.cancel();
    }
  }
}
