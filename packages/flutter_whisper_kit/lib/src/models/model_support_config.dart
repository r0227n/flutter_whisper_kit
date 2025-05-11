import 'model_support.dart';
import 'device_support.dart';

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
  final List<DeviceSupport> deviceSupports;

  /// List of all known model variants across all device supports.
  final List<String> knownModels;

  /// Default model support configuration for unknown devices.
  final ModelSupport defaultSupport;

  /// Creates a [ModelSupportConfig] from a JSON map.
  factory ModelSupportConfig.fromJson(Map<String, dynamic> json) {
    // Parse device supports
    final List<DeviceSupport> deviceSupports =
        (json['deviceSupports'] as List?)
            ?.map((e) => DeviceSupport.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse known models
    final List<String> knownModels =
        (json['knownModels'] as List?)?.map((e) => e as String).toList() ?? [];

    // Parse default support
    final ModelSupport defaultSupport =
        json['defaultSupport'] != null
            ? ModelSupport.fromJson(
              json['defaultSupport'] as Map<String, dynamic>,
            )
            : ModelSupport(supported: [], defaultModel: 'tiny', disabled: []);

    return ModelSupportConfig(
      repoName: json['name'] as String? ?? '',
      repoVersion: json['repoVersion'] as String? ?? '',
      deviceSupports: deviceSupports,
      knownModels: knownModels,
      defaultSupport: defaultSupport,
    );
  }

  /// Converts this [ModelSupportConfig] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'repoVersion': repoVersion,
      'deviceSupports': deviceSupports.map((e) => e.toJson()).toList(),
      'knownModels': knownModels,
      'defaultSupport': defaultSupport.toJson(),
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
      deviceSupports:
          deviceSupports.isEmpty ? fallback.deviceSupports : deviceSupports,
      knownModels: knownModels.isEmpty ? fallback.knownModels : knownModels,
      defaultSupport: defaultSupport,
    );
  }
}
