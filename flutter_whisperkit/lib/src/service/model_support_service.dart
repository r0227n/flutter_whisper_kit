import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:huggingface_client/huggingface_client.dart';

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
  
  /// Unknown error occurred.
  unknownError,
}

/// Service for fetching and managing model support configurations.
class ModelSupportService {
  /// The Hugging Face client.
  final HuggingFaceClient _client;

  /// Creates a new [ModelSupportService] instance.
  ModelSupportService({String? token}) 
      : _client = HuggingFaceClient(token: token);

  /// Fetches model support configuration from the specified repository.
  /// 
  /// Parameters:
  /// - [repo]: The repository to fetch the configuration from (default: "argmaxinc/whisperkit-coreml")
  /// - [configPath]: Path to the configuration file in the repository (default: "config.json")
  /// - [revision]: Optional branch or commit hash
  /// - [forceRefresh]: Parameter kept for backward compatibility (no longer used)
  /// 
  /// Returns a [Future<Result<ModelSupportConfig>>] containing either the configuration or an error.
  Future<Result<ModelSupportConfig>> fetchModelSupportConfig({
    String repo = "argmaxinc/whisperkit-coreml",
    String configPath = "config.json",
    String? revision,
    bool forceRefresh = false,
  }) async {
    try {
      // Fetch from network
      final jsonString = await _client.getRepositoryFile(
        repo: repo,
        path: configPath,
        revision: revision,
      );

      // Parse JSON
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final config = ModelSupportConfig.fromJson(jsonMap);

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
