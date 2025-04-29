import '../flutter_whisperkit.dart';
import 'models.dart';

/// A class for loading and managing WhisperKit models.
class WhisperKitModelLoader {
  /// Creates a new WhisperKitModelLoader instance.
  WhisperKitModelLoader() : _whisperkit = FlutterWhisperkit();

  final FlutterWhisperkit _whisperkit;
  ModelStorageLocation _storageLocation = ModelStorageLocation.packageDirectory;

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
    ModelStorageLocation? storageLocation,
  }) async {
    return _whisperkit.loadModel(
      variant,
      modelRepo: modelRepo,
      redownload: redownload,
      storageLocation: storageLocation ?? _storageLocation,
    );
  }

  /// Sets the storage location for WhisperKit models.
  ///
  /// [location] - The storage location to use.
  void setStorageLocation(ModelStorageLocation location) {
    _storageLocation = location;
  }

  /// Gets the current storage location for WhisperKit models.
  ModelStorageLocation get storageLocation => _storageLocation;
}
