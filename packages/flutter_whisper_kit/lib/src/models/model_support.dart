/// Represents model support information for a device.
class ModelSupport {
  /// Creates a new [ModelSupport] instance.
  const ModelSupport({
    required this.defaultModel,
    required this.supported,
    required this.disabled,
  });

  /// List of model variants supported by the device.
  final String defaultModel;

  /// The default model variant recommended for the device.
  final List<String> supported;

  /// List of model variants that are explicitly disabled for the device.
  final List<String> disabled;

  /// Creates a [ModelSupport] from a JSON map.
  factory ModelSupport.fromJson(Map<String, dynamic> json) {
    return ModelSupport(
      defaultModel: json['default'] as String? ?? 'tiny',
      supported:
          (json['supported'] as List?)?.map((e) => e as String).toList() ?? [],

      disabled:
          (json['disabled'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  /// Converts this [ModelSupport] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'default': defaultModel,
      'supported': supported,

      'disabled': disabled,
    };
  }
}
