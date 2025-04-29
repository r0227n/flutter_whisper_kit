import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple.dart';
import 'src/models.dart';

import 'flutter_whisperkit_platform_interface.dart';

/// An implementation of [FlutterWhisperkitPlatform] that uses method channels.
class MethodChannelFlutterWhisperkit extends FlutterWhisperkitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_whisperkit');

  /// The instance of flutter_whisperkit_apple that this method channel delegates to.
  final _whisperKitApple = FlutterWhisperkitApple();

  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  }) {
    return _whisperKitApple.loadModel(
      variant,
      modelRepo: modelRepo,
      redownload: redownload,
      storageLocation: storageLocation,
    );
  }

  @override
  Future<String?> transcribeFromFile(
    String filePath,
    DecodingOptions options,
  ) async {
    try {
      final result = await _whisperKitApple.transcribeFromFile(
        filePath,
        options: options,
      );
      // Convert the TranscriptionResult to a JSON string to pass through the platform interface
      return jsonEncode(result.toJson());
    } catch (e) {
      debugPrint('Error transcribing file: $e');
      rethrow;
    }
  }

  @override
  Future<String?> startRecording(DecodingOptions options, bool loop) {
    return _whisperKitApple.startRecording(options: options, loop: loop);
  }

  @override
  Future<String?> stopRecording(bool loop) {
    return _whisperKitApple.stopRecording(loop: loop);
  }

  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _whisperKitApple.transcriptionStream;
}
