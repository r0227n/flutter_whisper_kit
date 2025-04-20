import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_whisperkit_apple_platform_interface.dart';

/// An implementation of [FlutterWhisperkitApplePlatform] that uses method channels.
class MethodChannelFlutterWhisperkitApple
    extends FlutterWhisperkitApplePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_whisperkit_apple');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> createWhisperKit(String? model, String? modelRepo) async {
    try {
      final result = await methodChannel.invokeMethod<String>(
        'createWhisperKit',
        {
          'model': model,
          'modelRepo': modelRepo,
        },
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error creating WhisperKit: ${e.message}');
      throw e;
    }
  }

  @override
  Future<String?> transcribeCurrentFile(String? filePath) async {
    try {
      final result = await methodChannel.invokeMethod<String>(
        'transcribeCurrentFile',
        {
          'filePath': filePath,
        },
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error transcribing file: ${e.message}');
      throw e;
    }
  }
}
