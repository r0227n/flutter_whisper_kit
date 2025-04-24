import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whisperkit_apple/src/models/decoding_options.dart';

import 'flutter_whisperkit_apple_platform_interface.dart';
import 'src/whisper_kit_message.g.dart';

/// An implementation of [FlutterWhisperkitApplePlatform] that uses method channels.
class MethodChannelFlutterWhisperkitApple
    extends FlutterWhisperkitApplePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_whisperkit_apple');

  /// The Pigeon-generated API for WhisperKit
  final _whisperKitMessage = WhisperKitMessage();

  @override
  Future<String?> getPlatformVersion() async {
    return _whisperKitMessage.getPlatformVersion();
  }

  @override
  Future<String?> createWhisperKit(String? model, String? modelRepo) async {
    try {
      return _whisperKitMessage.createWhisperKit(model, modelRepo);
    } on PlatformException catch (e) {
      debugPrint('Error creating WhisperKit: ${e.message}');
      throw e;
    }
  }

  @override
  Future<String?> loadModel(
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  ) async {
    try {
      return _whisperKitMessage.loadModel(
        variant,
        modelRepo,
        redownload,
        storageLocation,
      );
    } on PlatformException catch (e) {
      debugPrint('Error loading model: ${e.message}');
      throw e;
    }
  }

  @override
  Future<String?> transcribeFromFile(
    String filePath,
    DecodingOptions options,
  ) async {
    try {
      return _whisperKitMessage.transcribeFromFile(filePath, options.toJson());
    } on PlatformException catch (e) {
      debugPrint('Error transcribing file: ${e.message}');
      throw e;
    }
  }
}
