
import 'flutter_whisperkit_apple_platform_interface.dart';

class FlutterWhisperkitApple {
  Future<String?> getPlatformVersion() {
    return FlutterWhisperkitApplePlatform.instance.getPlatformVersion();
  }
  
  /// Creates a WhisperKit instance with the specified model and model repository.
  ///
  /// [model] - The name of the model to use (e.g., "large-v3").
  /// [modelRepo] - The repository containing the model (e.g., "username/your-model-repo").
  ///
  /// Returns a success message if the WhisperKit instance was created successfully,
  /// or throws a [PlatformException] if an error occurred.
  Future<String?> createWhisperKit(String model, String modelRepo) {
    return FlutterWhisperkitApplePlatform.instance.createWhisperKit(model, modelRepo);
  }
}
