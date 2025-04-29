import '../model/model_support_config.dart';
import '../service/model_support_service.dart';

/// API for fetching and managing model support configurations.
class ModelSupportApi {
  /// The model support service.
  final ModelSupportService _service;
  
  /// Creates a new [ModelSupportApi] instance.
  ModelSupportApi({String? token}) 
      : _service = ModelSupportService(token: token);

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
    return _service.fetchModelSupportConfig(
      repo: repo,
      configPath: configPath,
      revision: revision,
      forceRefresh: forceRefresh,
    );
  }


  /// Checks if the specified model is supported on the current device.
  Future<bool> isModelSupported(ModelSupportConfig config, String modelName) {
    return _service.isModelSupported(config, modelName);
  }

  /// Gets the list of supported models for the current device.
  Future<List<String>> getSupportedModels(ModelSupportConfig config) {
    return _service.getSupportedModels(config);
  }

  /// Gets the default model for the current device.
  Future<String> getDefaultModel(ModelSupportConfig config) {
    return _service.getDefaultModel(config);
  }
}
