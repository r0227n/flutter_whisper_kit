import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:huggingface_client/huggingface_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/model_support_config.dart';

/// Result class for handling success and error states.
class Result<T> {
  /// The data returned on success.
  final T? data;
  
  /// The error type if an error occurred.
  final ModelSupportConfigError? error;
  
  /// Additional error message.
  final String? message;

  /// Creates a success result with data.
  Result.success(this.data) : error = null, message = null;

  /// Creates an error result with error type and optional message.
  Result.error(this.error, [this.message]) : data = null;

  /// Whether this result represents a success.
  bool get isSuccess => error == null;
}

/// Error types for model support configuration operations.
enum ModelSupportConfigError {
  /// Error occurred during network request.
  networkError,
  
  /// Error occurred when parsing JSON.
  jsonParsingError,
  
  /// Error occurred when accessing the Hugging Face API.
  huggingFaceApiError,
  
  /// Error occurred when accessing the file system.
  fileSystemError,
  
  /// Error occurred when accessing shared preferences.
  preferencesError,
  
  /// Unknown error occurred.
  unknownError,
}

/// Service for fetching and managing model support configurations.
class ModelSupportService {
  /// The Hugging Face client.
  final HuggingFaceClient _client;
  
  /// Cache key prefix for shared preferences.
  static const String _cacheKeyPrefix = 'whisperkit_model_support_config_';

  /// Creates a new [ModelSupportService] instance.
  ModelSupportService({String? token}) 
      : _client = HuggingFaceClient(token: token);

  /// Fetches model support configuration from the specified repository.
  /// 
  /// Parameters:
  /// - [repo]: The repository to fetch the configuration from (default: "argmaxinc/whisperkit-coreml")
  /// - [configPath]: Path to the configuration file in the repository (default: "config.json")
  /// - [revision]: Optional branch or commit hash
  /// - [forceRefresh]: Whether to force a refresh from the network (default: false)
  /// 
  /// Returns a [Future<Result<ModelSupportConfig>>] containing either the configuration or an error.
  Future<Result<ModelSupportConfig>> fetchModelSupportConfig({
    String repo = "argmaxinc/whisperkit-coreml",
    String configPath = "config.json",
    String? revision,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh) {
        final cachedConfig = await _getCachedConfig(repo, configPath, revision);
        if (cachedConfig != null) {
          return Result.success(cachedConfig);
        }
      }

      // Fetch from network
      final jsonString = await _client.getRepositoryFile(
        repo: repo,
        path: configPath,
        revision: revision,
      );

      // Parse JSON
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final config = ModelSupportConfig.fromJson(jsonMap);

      // Cache the result
      await _cacheConfig(repo, configPath, revision, jsonString);

      return Result.success(config);
    } on HuggingFaceClientException catch (e) {
      return Result.error(
        ModelSupportConfigError.huggingFaceApiError,
        'HuggingFace API error: ${e.message}',
      );
    } on SocketException catch (e) {
      return Result.error(
        ModelSupportConfigError.networkError,
        'Network error: ${e.message}',
      );
    } on FormatException catch (e) {
      return Result.error(
        ModelSupportConfigError.jsonParsingError,
        'JSON parsing error: ${e.message}',
      );
    } catch (e) {
      return Result.error(
        ModelSupportConfigError.unknownError,
        'Unknown error: $e',
      );
    }
  }

  /// Gets cached configuration from shared preferences or file system.
  Future<ModelSupportConfig?> _getCachedConfig(
    String repo,
    String configPath,
    String? revision,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(repo, configPath, revision);
      
      // Check if cache exists
      if (prefs.containsKey(cacheKey)) {
        // Get cache timestamp
        final timestamp = prefs.getInt('${cacheKey}_timestamp') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Check if cache is still valid (24 hours)
        if (now - timestamp < 24 * 60 * 60 * 1000) {
          // Get cached file path
          final filePath = prefs.getString(cacheKey);
          if (filePath != null) {
            final file = File(filePath);
            if (await file.exists()) {
              final jsonString = await file.readAsString();
              final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
              return ModelSupportConfig.fromJson(jsonMap);
            }
          }
        }
      }
      
      return null;
    } catch (e) {
      // If there's an error reading the cache, return null to fetch from network
      debugPrint('Error reading cache: $e');
      return null;
    }
  }

  /// Caches configuration to shared preferences and file system.
  /// Does not cache locale-specific data as per requirements.
  Future<void> _cacheConfig(
    String repo,
    String configPath,
    String? revision,
    String jsonString,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(repo, configPath, revision);
      
      // Parse JSON to remove any locale-specific data before caching
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      
      // Remove any locale-specific data if present
      // This is a placeholder - implement based on actual locale fields in your config
      if (jsonMap.containsKey('locale')) {
        jsonMap.remove('locale');
      }
      
      // Convert back to string
      final filteredJsonString = jsonEncode(jsonMap);
      
      // Save to file
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/whisperkit_config_cache/$cacheKey.json');
      
      // Create directory if it doesn't exist
      await file.parent.create(recursive: true);
      
      // Write to file
      await file.writeAsString(filteredJsonString);
      
      // Save to shared preferences
      await prefs.setString(cacheKey, file.path);
      await prefs.setInt(
        '${cacheKey}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // If there's an error caching, just log it and continue
      debugPrint('Error caching config: $e');
    }
  }

  /// Gets cache key for the specified repository and configuration path.
  String _getCacheKey(String repo, String configPath, String? revision) {
    final revisionPart = revision != null ? '_$revision' : '';
    return '$_cacheKeyPrefix${repo.replaceAll('/', '_')}_${configPath.replaceAll('/', '_')}$revisionPart';
  }

  /// Clears the cached configuration.
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Remove all keys related to model support config
      for (final key in keys) {
        if (key.startsWith(_cacheKeyPrefix)) {
          await prefs.remove(key);
        }
      }
      
      // Remove cache files
      final directory = await getApplicationSupportDirectory();
      final cacheDir = Directory('${directory.path}/whisperkit_config_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Checks if the specified model is supported on the current device.
  Future<bool> isModelSupported(ModelSupportConfig config, String modelName) async {
    final deviceIdentifier = await _getDeviceIdentifier();
    final deviceSupport = config.getDeviceSupport(deviceIdentifier);
    return deviceSupport.models.supported.contains(modelName);
  }

  /// Gets the list of supported models for the current device.
  Future<List<String>> getSupportedModels(ModelSupportConfig config) async {
    final deviceIdentifier = await _getDeviceIdentifier();
    final deviceSupport = config.getDeviceSupport(deviceIdentifier);
    return deviceSupport.models.supported;
  }

  /// Gets the default model for the current device.
  Future<String> getDefaultModel(ModelSupportConfig config) async {
    final deviceIdentifier = await _getDeviceIdentifier();
    final deviceSupport = config.getDeviceSupport(deviceIdentifier);
    return deviceSupport.models.defaultModel;
  }

  /// Gets the device identifier.
  Future<String> _getDeviceIdentifier() async {
    // This would be implemented to get the actual device identifier
    // For now, return a placeholder
    return 'iPhone14,7';
  }
}
