import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_whisperkit/flutter_whisperkit.dart';
import 'package:flutter_whisperkit/src/api/model_support_api.dart';
import 'package:flutter_whisperkit/src/model/model_support_config.dart';
import 'package:flutter_whisperkit/src/service/model_support_service.dart';

/// Main class for WhisperKit model support functionality.
/// This class delegates to the flutter_whisperkit package implementation.
class WhisperKitModelSupport {
  static const MethodChannel _channel = MethodChannel('flutter_whisperkit_apple');
  
  /// The FlutterWhisperkit instance.
  final FlutterWhisperkit _whisperkit;
  
  /// Creates a new [WhisperKitModelSupport] instance.
  WhisperKitModelSupport({String? token}) 
      : _whisperkit = FlutterWhisperkit(token: token);

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
  }) {
    return _whisperkit.modelSupport.fetchModelSupportConfig(
      repo: repo,
      configPath: configPath,
      revision: revision,
      forceRefresh: forceRefresh,
    );
  }

  /// Gets the platform version.
  Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }


  /// Checks if the specified model is supported on the current device.
  Future<bool> isModelSupported(ModelSupportConfig config, String modelName) {
    return _whisperkit.modelSupport.isModelSupported(config, modelName);
  }

  /// Gets the list of supported models for the current device.
  Future<List<String>> getSupportedModels(ModelSupportConfig config) {
    return _whisperkit.modelSupport.getSupportedModels(config);
  }

  /// Gets the default model for the current device.
  Future<String> getDefaultModel(ModelSupportConfig config) {
    return _whisperkit.modelSupport.getDefaultModel(config);
  }
}
