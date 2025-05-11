/// Represents model support information for a device.
class ModelSupport {
  /// Creates a new [ModelSupport] instance.
  const ModelSupport({
    required this.supportedModels,
    required this.defaultModel,
    this.disabledModels = const [],
  });

  /// List of model variants supported by the device.
  final List<String> supportedModels;

  /// The default model variant recommended for the device.
  final String defaultModel;

  /// List of model variants that are explicitly disabled for the device.
  final List<String> disabledModels;

  /// Creates a [ModelSupport] from a JSON map.
  factory ModelSupport.fromJson(Map<String, dynamic> json) {
    return ModelSupport(
      supportedModels: (json['supportedModels'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      defaultModel: json['defaultModel'] as String? ?? 'tiny',
      disabledModels: (json['disabledModels'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Converts this [ModelSupport] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'supportedModels': supportedModels,
      'defaultModel': defaultModel,
      'disabledModels': disabledModels,
    };
  }
}
