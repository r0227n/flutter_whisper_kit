import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_whisperkit_platform_interface.dart';

/// An implementation of [FlutterWhisperkitPlatform] that uses method channels.
class MethodChannelFlutterWhisperkit extends FlutterWhisperkitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_whisperkit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
