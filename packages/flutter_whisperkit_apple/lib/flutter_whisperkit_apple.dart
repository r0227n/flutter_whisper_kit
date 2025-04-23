import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'flutter_whisperkit_apple_platform_interface.dart';
import 'src/models/transcription_result.dart';

/// The main entry point for the Flutter WhisperKit Apple plugin.
class FlutterWhisperkitApple {
  /// Returns the platform version.
  Future<String?> getPlatformVersion() {
    return FlutterWhisperkitApplePlatform.instance.getPlatformVersion();
  }

  /// Creates a WhisperKit instance.
  ///
  /// [model] - The model name to use.
  /// [modelRepo] - The repository to download the model from.
  Future<String?> createWhisperKit(String? model, String? modelRepo) {
    return FlutterWhisperkitApplePlatform.instance.createWhisperKit(
      model,
      modelRepo,
    );
  }

  /// Loads a WhisperKit model.
  ///
  /// [variant] - The model variant to load (e.g., 'tiny-en', 'base', 'small', 'medium', 'large-v2').
  /// [modelRepo] - The repository to download the model from (default: 'argmaxinc/whisperkit-coreml').
  /// [redownload] - Whether to force redownload the model even if it exists locally.
  /// [storageLocation] - Where to store the model (0: package directory, 1: user folder).
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  }) {
    return FlutterWhisperkitApplePlatform.instance.loadModel(
      variant,
      modelRepo,
      redownload,
      storageLocation,
    );
  }

  /// Transcribes an audio file at the specified path.
  ///
  /// [filePath] - The path to the audio file to transcribe.
  ///
  /// Returns a JSON string containing the transcription result with segments and timing information.
  Future<String?> transcribeFromFile(String filePath) {
    return FlutterWhisperkitApplePlatform.instance.transcribeFromFile(filePath);
  }

  /// Transcribes an audio file at the specified path and returns a parsed [TranscriptionResult].
  ///
  /// [filePath] - The path to the audio file to transcribe.
  ///
  /// Returns a [TranscriptionResult] object containing the transcription segments and timing information.
  Future<TranscriptionResult?> transcribeFromFileAndParse(
    String filePath,
  ) async {
    final jsonString = await transcribeFromFile(filePath);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return TranscriptionResult.fromJson(json);
    } catch (e) {
      debugPrint('Error parsing transcription result: $e');
      rethrow;
    }
  }
}
