import 'package:collection/collection.dart';

/// Represents the configuration for model support in WhisperKit.
class ModelSupportConfig {
  /// The name of the repository containing the models.
  final String repoName;
  
  /// The version of the repository.
  final String repoVersion;
  
  /// List of device support configurations.
  final List<DeviceSupport> deviceSupports;
  
  /// List of all known model names, computed on initialization.
  final List<String> knownModels;
  
  /// Default device support for unknown devices.
  final DeviceSupport defaultSupport;

  /// Creates a new [ModelSupportConfig] instance.
  ///
  /// [repoName] The name of the repository.
  /// [repoVersion] The version of the repository.
  /// [deviceSupports] List of device support configurations.
  /// [includeFallback] Whether to include fallback configurations.
  ModelSupportConfig({
    required this.repoName,
    required this.repoVersion,
    required List<DeviceSupport> deviceSupports,
    bool includeFallback = true,
  }) : knownModels = _computeKnownModels(deviceSupports),
       defaultSupport = DeviceSupport(
         identifiers: [],
         models: ModelSupport(
           defaultModel: 'openai_whisper-base',
           supported: _computeKnownModels(deviceSupports),
         ),
       ),
       deviceSupports = includeFallback && Constants.fallbackModelSupportConfig.repoName.contains(repoName)
           ? _mergeDeviceSupport(remote: deviceSupports, fallback: Constants.fallbackModelSupportConfig.deviceSupports)
           : deviceSupports {
    _computeDisabledModels();
  }

  /// Creates a [ModelSupportConfig] from JSON data.
  factory ModelSupportConfig.fromJson(Map<String, dynamic> json) {
    return ModelSupportConfig(
      repoName: json['name'] as String,
      repoVersion: json['version'] as String,
      deviceSupports: (json['device_support'] as List)
          .map((e) => DeviceSupport.fromJson(e as Map<String, dynamic>))
          .toList(),
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

  /// Computes the list of known models from device supports.
  static List<String> _computeKnownModels(List<DeviceSupport> deviceSupports) {
    final allModels = deviceSupports
        .expand((support) => support.models.supported)
        .toList();
    
    // Remove duplicates while preserving order (similar to orderedSet in Swift)
    return allModels.toSet().toList();
  }

  /// Merges remote and fallback device support configurations.
  static List<DeviceSupport> _mergeDeviceSupport({
    required List<DeviceSupport> remote,
    required List<DeviceSupport> fallback,
  }) {
    // Implementation would merge remote and fallback configurations
    // This is a simplified version of the Swift implementation
    final result = List<DeviceSupport>.from(remote);
    
    for (final fallbackSupport in fallback) {
      final existingIndex = result.indexWhere(
        (support) => const ListEquality().equals(
          support.identifiers, fallbackSupport.identifiers
        )
      );
      
      if (existingIndex == -1) {
        // Add fallback support if not present in remote
        result.add(fallbackSupport);
      }
    }
    
    return result;
  }

  /// Computes disabled models for each device support.
  void _computeDisabledModels() {
    for (final support in deviceSupports) {
      support.models.disabled = knownModels
          .where((model) => !support.models.supported.contains(model))
          .toList();
    }
  }

  /// Gets the device support for the specified device identifier.
  DeviceSupport getDeviceSupport(String deviceIdentifier) {
    return deviceSupports.firstWhere(
      (support) => support.identifiers.contains(deviceIdentifier),
      orElse: () => defaultSupport,
    );
  }
}

/// Represents device-specific support configuration.
class DeviceSupport {
  /// List of device identifiers this support applies to.
  final List<String> identifiers;
  
  /// Model support configuration for this device.
  final ModelSupport models;

  /// Creates a new [DeviceSupport] instance.
  DeviceSupport({
    required this.identifiers,
    required this.models,
  });

  /// Creates a [DeviceSupport] from JSON data.
  factory DeviceSupport.fromJson(Map<String, dynamic> json) {
    return DeviceSupport(
      identifiers: (json['identifiers'] as List).cast<String>(),
      models: ModelSupport.fromJson(json['models'] as Map<String, dynamic>),
    );
  }

  /// Converts this [DeviceSupport] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'identifiers': identifiers,
      'models': models.toJson(),
    };
  }
}

/// Represents model support configuration.
class ModelSupport {
  /// The default model to use.
  final String defaultModel;
  
  /// List of supported models.
  final List<String> supported;
  
  /// List of disabled models, computed during initialization.
  List<String> disabled = [];

  /// Creates a new [ModelSupport] instance.
  ModelSupport({
    required this.defaultModel,
    required this.supported,
  });

  /// Creates a [ModelSupport] from JSON data.
  factory ModelSupport.fromJson(Map<String, dynamic> json) {
    return ModelSupport(
      defaultModel: json['default'] as String,
      supported: (json['supported'] as List).cast<String>(),
    );
  }

  /// Converts this [ModelSupport] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'default': defaultModel,
      'supported': supported,
    };
  }
}

/// Constants used by the ModelSupportConfig.
class Constants {
  /// Fallback model support configuration.
  static final ModelSupportConfig fallbackModelSupportConfig = ModelSupportConfig(
    repoName: 'argmaxinc/whisperkit-coreml',
    repoVersion: '1.0.0',
    deviceSupports: [
      DeviceSupport(
        identifiers: ['iPhone14,7', 'iPhone14,8', 'iPhone15,2', 'iPhone15,3', 'iPhone15,4', 'iPhone15,5'],
        models: ModelSupport(
          defaultModel: 'openai_whisper-base',
          supported: ['openai_whisper-tiny', 'openai_whisper-base', 'openai_whisper-small'],
        ),
      ),
      DeviceSupport(
        identifiers: ['iPhone12,1', 'iPhone12,3', 'iPhone12,5', 'iPhone13,1', 'iPhone13,2', 'iPhone13,3', 'iPhone13,4', 'iPhone14,4', 'iPhone14,5', 'iPhone14,2', 'iPhone14,3'],
        models: ModelSupport(
          defaultModel: 'openai_whisper-tiny',
          supported: ['openai_whisper-tiny', 'openai_whisper-base'],
        ),
      ),
    ],
    includeFallback: false,
  );
}
