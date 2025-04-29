import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';

import 'flutter_whisperkit_apple_method_channel.dart';

/// The Apple implementation of [FlutterWhisperkitPlatform].
class FlutterWhisperkitApple {
  /// Register this implementation with the platform interface.
  static void registerWith() {
    FlutterWhisperkitPlatform.instance = MethodChannelFlutterWhisperkitApple();
  }
}
