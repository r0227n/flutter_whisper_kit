import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';

/// An implementation of [FlutterWhisperkitPlatform] that uses method channels.
class MethodChannelFlutterWhisperkitApple extends FlutterWhisperkitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_whisperkit_apple');
}
