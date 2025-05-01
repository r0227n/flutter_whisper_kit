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
  /// [modelPath] - Path to the CoreML model file. If null, the app's internal directory will be used.
  ///               If the specified path does not exist, an exception will be thrown.
  /// [prewarmMode] - Whether to prewarm the model (true) or load it immediately (false).
  Future<String?> loadModel({
    required String variant,
    String modelRepo = 'argmaxinc/whisperkit-coreml',
    bool redownload = false,
    Function(double progress)? onProgress,
    String? modelPath,
    bool prewarmMode = true,
  }) async {
    return _whisperkit.loadModel(
      variant,
      modelRepo: modelRepo,
      redownload: redownload,
      modelPath: modelPath,
      prewarmMode: prewarmMode,
    );
  }
}
