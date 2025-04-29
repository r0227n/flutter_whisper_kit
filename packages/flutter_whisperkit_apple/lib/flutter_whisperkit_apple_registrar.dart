import 'package:flutter/foundation.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';

import 'flutter_whisperkit_apple_platform_interface.dart';

/// Registers the Apple implementation of the Flutter WhisperKit platform interface.
class FlutterWhisperkitAppleRegistrar {
  /// Registers the Apple implementation.
  ///
  /// This method should be called in the platform's plugin registration method.
  static void registerWith() {
    // Only set the implementation if we're on Apple platforms
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      FlutterWhisperkitPlatform.instance = FlutterWhisperkitApplePlatform.instance;
    }
  }
}
