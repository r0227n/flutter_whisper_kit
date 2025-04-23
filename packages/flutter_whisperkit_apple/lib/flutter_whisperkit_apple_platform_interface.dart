import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_whisperkit_apple_method_channel.dart';

abstract class FlutterWhisperkitApplePlatform extends PlatformInterface {
  /// Constructs a FlutterWhisperkitApplePlatform.
  FlutterWhisperkitApplePlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWhisperkitApplePlatform _instance =
      MethodChannelFlutterWhisperkitApple();

  /// The default instance of [FlutterWhisperkitApplePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWhisperkitApple].
  static FlutterWhisperkitApplePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWhisperkitApplePlatform] when
  /// they register themselves.
  static set instance(FlutterWhisperkitApplePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> createWhisperKit(String? model, String? modelRepo) {
    throw UnimplementedError('createWhisperKit() has not been implemented.');
  }

  Future<String?> loadModel(
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  ) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  Future<String?> transcribeFromFile(String? filePath, Map<String, dynamic>? options) {
    throw UnimplementedError('transcribeFromFile() has not been implemented.');
  }
}
