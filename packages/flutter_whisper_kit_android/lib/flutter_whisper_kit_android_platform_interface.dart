import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_whisper_kit_android_method_channel.dart';

abstract class FlutterWhisperKitAndroidPlatform extends PlatformInterface {
  /// Constructs a FlutterWhisperKitAndroidPlatform.
  FlutterWhisperKitAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWhisperKitAndroidPlatform _instance = MethodChannelFlutterWhisperKitAndroid();

  /// The default instance of [FlutterWhisperKitAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWhisperKitAndroid].
  static FlutterWhisperKitAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWhisperKitAndroidPlatform] when
  /// they register themselves.
  static set instance(FlutterWhisperKitAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
