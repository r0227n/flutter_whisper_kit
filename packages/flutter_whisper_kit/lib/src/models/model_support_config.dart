import 'package:flutter_whisper_kit/src/models/model_support.dart';

/// Represents the model support configuration for WhisperKit.
class ModelSupportConfig {
  /// Creates a new [ModelSupportConfig] instance.
  const ModelSupportConfig({
    required this.repoName,
    required this.repoVersion,
    required this.deviceSupports,
    required this.knownModels,
    required this.defaultSupport,
  });

  /// The name of the repository containing the models.
  final String repoName;

  /// The version of the repository.
  final String repoVersion;

  /// List of device-specific model support configurations.
  final List<ModelSupport> deviceSupports;

  /// List of all known model variants across all device supports.
  final List<String> knownModels;

  /// Default model support configuration for unknown devices.
  final ModelSupport defaultSupport;

  /// Creates a [ModelSupportConfig] from a JSON map.
  factory ModelSupportConfig.fromJson(Map<String, dynamic> json) {
    // Parse device supports
    final List<ModelSupport> deviceSupports = (json['device_support'] as List?)
            ?.map((e) => ModelSupport.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Compute known models by flattening all supported models
    final Set<String> knownModelsSet = {};
    for (final support in deviceSupports) {
      knownModelsSet.addAll(support.supportedModels);
    }
    final List<String> knownModels = knownModelsSet.toList()..sort();

    // Create default support for unknown devices that supports all known models
    final ModelSupport defaultSupport = ModelSupport(
      supportedModels: knownModels,
      defaultModel: 'tiny',
      disabledModels: [],
    );

    return ModelSupportConfig(
      repoName: json['name'] as String? ?? '',
      repoVersion: json['version'] as String? ?? '',
      deviceSupports: deviceSupports,
      knownModels: knownModels,
      defaultSupport: defaultSupport,
    );
  }

  /// Converts this [ModelSupportConfig] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': repoName,
      'version': repoVersion,
      'device_support': deviceSupports.map((e) => e.toJson()).toList(),
    };
  }

  /// Merges this configuration with a fallback configuration.
  ///
  /// If this configuration is empty or incomplete, values from the fallback
  /// configuration will be used.
  ModelSupportConfig mergeWithFallback(ModelSupportConfig fallback) {
    if (deviceSupports.isEmpty) {
      return fallback;
    }

    // Use values from this config, falling back to the fallback config
    return ModelSupportConfig(
      repoName: repoName.isEmpty ? fallback.repoName : repoName,
      repoVersion: repoVersion.isEmpty ? fallback.repoVersion : repoVersion,
      deviceSupports: deviceSupports.isEmpty ? fallback.deviceSupports : deviceSupports,
      knownModels: knownModels.isEmpty ? fallback.knownModels : knownModels,
      defaultSupport: defaultSupport,
    );
  }
}
