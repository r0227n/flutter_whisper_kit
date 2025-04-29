import 'dart:convert';
import 'dart:io';

import 'package:huggingface_client/huggingface_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/model_support_config.dart';

/// Error types for model support configuration operations.
enum ModelSupportConfigError {
  networkError,
  parsingError,
  fileSystemError,
  invalidConfiguration,
  unsupportedDevice,
  huggingFaceApiError,
}

/// Result class for handling success and failure cases.
class Result<T> {
  /// The data returned on success.
  final T? data;
  
  /// The error type on failure.
  final ModelSupportConfigError? error;
  
  /// Error message on failure.
  final String? message;

  /// Whether the operation was successful.
  bool get isSuccess => error == null;

  /// Creates a new [Result] instance.
  Result({this.data, this.error, this.message});

  /// Creates a success result with data.
  factory Result.success(T data) => Result(data: data);

  /// Creates a failure result with error and optional message.
  factory Result.failure(ModelSupportConfigError error, [String? message]) => 
      Result(error: error, message: message);
}

/// Service for fetching and managing model support configurations.
class ModelSupportService {
  /// The Hugging Face client for API communication.
  final HuggingFaceClient _client;
  
  /// Key for storing the cached configuration timestamp.
  static const String _cacheTimestampKey = 'model_support_config_timestamp';
  
  /// Key for storing the cached configuration repository.
  static const String _cacheRepoKey = 'model_support_config_repo';
  
  /// Default cache duration in milliseconds (24 hours).
  static const int _defaultCacheDuration = 24 * 60 * 60 * 1000;

  /// Creates a new [ModelSupportService] instance.
  ModelSupportService({String? token}) 
      : _client = HuggingFaceClient(token: token);

  /// Fetches model support configuration from the specified repository.
  /// 
  /// [repo] The repository to fetch the configuration from.
  /// [configPath] Path to the configuration file in the repository.
  /// [revision] Optional branch or commit hash.
  /// [forceRefresh] Whether to force a refresh from the network.
  Future<Result<ModelSupportConfig>> fetchModelSupportConfig({
    String repo = "argmaxinc/whisperkit-coreml",
    String configPath = "config.json",
    String? revision,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh) {
        final cachedConfig = await _getCachedConfig(repo);
        if (cachedConfig != null) {
          return Result.success(cachedConfig);
        }
      }

      // Fetch from Hugging Face API
      final configResult = await _fetchConfigFile(
        repo: repo,
        path: configPath,
        revision: revision,
      );

      if (!configResult.isSuccess) {
        return Result.failure(
          configResult.error!,
          configResult.message,
        );
      }

      // Parse configuration
      try {
        final configJson = jsonDecode(configResult.data!) as Map<String, dynamic>;
        final config = ModelSupportConfig.fromJson(configJson);
        
        // Cache the configuration
        await _cacheConfig(config, repo);
        
        return Result.success(config);
      } catch (e) {
        return Result.failure(
          ModelSupportConfigError.parsingError,
          'Failed to parse configuration: ${e.toString()}',
        );
      }
    } catch (e) {
      return Result.failure(
        ModelSupportConfigError.networkError,
        'Failed to fetch model support configuration: ${e.toString()}',
      );
    }
  }

  /// Fetches a configuration file from the Hugging Face repository.
  Future<Result<String>> _fetchConfigFile({
    required String repo,
    required String path,
    String? revision,
  }) async {
    try {
      final response = await _client.getRepositoryFile(
        repo: repo,
        path: path,
        revision: revision,
      );
      
      return Result.success(response);
    } catch (e) {
      return Result.failure(
        ModelSupportConfigError.huggingFaceApiError,
        'Failed to fetch config file: ${e.toString()}',
      );
    }
  }

  /// Caches the configuration to local storage.
  Future<void> _cacheConfig(ModelSupportConfig config, String repo) async {
    try {
      // Save to file system
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/model_support_config.json');
      await file.writeAsString(jsonEncode(config.toJson()));
      
      // Save timestamp and repo in preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setString(_cacheRepoKey, repo);
    } catch (e) {
      // Silently fail on cache errors
      print('Failed to cache configuration: ${e.toString()}');
    }
  }

  /// Retrieves the cached configuration if available and not expired.
  Future<ModelSupportConfig?> _getCachedConfig(String repo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      final cachedRepo = prefs.getString(_cacheRepoKey);
      
      // Check if cache is valid
      if (timestamp == null || 
          cachedRepo == null || 
          cachedRepo != repo ||
          _isCacheExpired(timestamp)) {
        return null;
      }
      
      // Read from file system
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/model_support_config.json');
      
      if (!await file.exists()) {
        return null;
      }
      
      final jsonString = await file.readAsString();
      final configJson = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return ModelSupportConfig.fromJson(configJson);
    } catch (e) {
      // Return null on any cache error
      print('Failed to get cached configuration: ${e.toString()}');
      return null;
    }
  }

  /// Checks if the cache is expired based on timestamp.
  bool _isCacheExpired(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp > _defaultCacheDuration;
  }

  /// Clears the cached configuration.
  Future<void> clearCache() async {
    try {
      // Clear preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheTimestampKey);
      await prefs.remove(_cacheRepoKey);
      
      // Delete cache file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/model_support_config.json');
      
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Failed to clear cache: ${e.toString()}');
    }
  }

  /// Gets the device support for the current device.
  Future<DeviceSupport> getDeviceSupportForCurrentDevice(ModelSupportConfig config) async {
    // In a real implementation, this would detect the actual device model
    // For now, we'll use a placeholder implementation
    final deviceIdentifier = await _getDeviceIdentifier();
    return config.getDeviceSupport(deviceIdentifier);
  }

  /// Gets the device identifier for the current device.
  Future<String> _getDeviceIdentifier() async {
    // This is a placeholder implementation
    // In a real implementation, this would use platform-specific code to get the device model
    if (Platform.isIOS) {
      return 'iPhone14,7'; // Example identifier for iPhone 13
    } else if (Platform.isMacOS) {
      return 'Mac14,6'; // Example identifier for MacBook Pro
    } else {
      return 'unknown';
    }
  }

  /// Checks if the specified model is supported on the current device.
  Future<bool> isModelSupported(ModelSupportConfig config, String modelName) async {
    final deviceSupport = await getDeviceSupportForCurrentDevice(config);
    return deviceSupport.models.supported.contains(modelName);
  }

  /// Gets the list of supported models for the current device.
  Future<List<String>> getSupportedModels(ModelSupportConfig config) async {
    final deviceSupport = await getDeviceSupportForCurrentDevice(config);
    return deviceSupport.models.supported;
  }

  /// Gets the default model for the current device.
  Future<String> getDefaultModel(ModelSupportConfig config) async {
    final deviceSupport = await getDeviceSupportForCurrentDevice(config);
    return deviceSupport.models.defaultModel;
  }
}
