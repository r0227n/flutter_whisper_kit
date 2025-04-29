import 'src/whisperkit_model_support.dart';
export 'src/model/model_support_config.dart';
export 'src/service/model_support_service.dart';

/// Main class for the Flutter WhisperKit Apple plugin.
class FlutterWhisperkitApple {
  /// The WhisperKit model support functionality.
  final WhisperKitModelSupport modelSupport;

  /// Creates a new [FlutterWhisperkitApple] instance.
  FlutterWhisperkitApple({String? token})
    : modelSupport = WhisperKitModelSupport(token: token);
}
