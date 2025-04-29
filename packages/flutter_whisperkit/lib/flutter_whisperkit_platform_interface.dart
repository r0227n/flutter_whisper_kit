import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_whisperkit_method_channel.dart';

abstract class FlutterWhisperkitPlatform extends PlatformInterface {
  /// Constructs a FlutterWhisperkitPlatform.
  FlutterWhisperkitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWhisperkitPlatform _instance = MethodChannelFlutterWhisperkit();

  /// The default instance of [FlutterWhisperkitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWhisperkit].
  static FlutterWhisperkitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWhisperkitPlatform] when
  /// they register themselves.
  static set instance(FlutterWhisperkitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
