import 'flutter_whisperkit_apple.dart';

/// Storage location for WhisperKit models.
enum ModelStorageLocation {
  /// Store models in the application's package directory.
  packageDirectory,
  
  /// Store models in a user-accessible folder.
  userFolder,
}

/// A class for loading and managing WhisperKit models.
class WhisperKitModelLoader {
  /// Creates a new WhisperKitModelLoader instance.
  WhisperKitModelLoader() : _plugin = FlutterWhisperkitApple();
  
  final FlutterWhisperkitApple _plugin;
  
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
    ModelStorageLocation storageLocation = ModelStorageLocation.packageDirectory,
  }) async {
    return _plugin.loadModel(
      variant,
      modelRepo: modelRepo,
      redownload: redownload,
      storageLocation: storageLocation.index,
    );
  }
  
  /// Sets the storage location for WhisperKit models.
  ///
  /// [location] - The storage location to use.
  void setStorageLocation(ModelStorageLocation location) {
    // This is stored for future loadModel calls
    _storageLocation = location;
  }
  
  ModelStorageLocation _storageLocation = ModelStorageLocation.packageDirectory;
  
  /// Gets the current storage location for WhisperKit models.
  ModelStorageLocation get storageLocation => _storageLocation;
}
