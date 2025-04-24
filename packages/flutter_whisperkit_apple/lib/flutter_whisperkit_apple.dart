import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_whisperkit_apple/src/models/decoding_options.dart';

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
  /// [options] - Optional decoding options to customize the transcription process.
  ///
  /// Returns a JSON string containing the transcription result with segments and timing information.
  Future<TranscriptionResult> transcribeFromFile(
    String filePath, {
    DecodingOptions options = const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'ja',
      temperature: 0.0,
      temperatureFallbackCount: 5,
      sampleLength: 224,
      usePrefillPrompt: true,
      usePrefillCache: true,
      detectLanguage: true,
      skipSpecialTokens: true,
      withoutTimestamps: true,
      wordTimestamps: true,
      clipTimestamps: [0.0],
      concurrentWorkerCount: 4,
      chunkingStrategy: ChunkingStrategy.vad,
    ),
  }) async {
    final result = await FlutterWhisperkitApplePlatform.instance
        .transcribeFromFile(filePath, options);

    if (result == null) {
      throw Exception('Failed to execute transcription: result is null');
    }

    return TranscriptionResult.fromJson(
      jsonDecode(result) as Map<String, dynamic>,
    );
  }

  /// Transcribes an audio file at the specified path and returns a parsed [TranscriptionResult].
  ///
  /// [filePath] - The path to the audio file to transcribe.
  /// [options] - Optional decoding options to customize the transcription process.
  ///
  /// Returns a [TranscriptionResult] object containing the transcription segments and timing information.
  Future<TranscriptionResult?> transcribeFromFileAndParse(
    String filePath, {
    DecodingOptions options = const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'ja',
      temperature: 0.0,
      temperatureFallbackCount: 5,
      sampleLength: 224,
      usePrefillPrompt: true,
      usePrefillCache: true,
      detectLanguage: true,
      skipSpecialTokens: true,
      withoutTimestamps: true,
      wordTimestamps: true,
      clipTimestamps: [0.0],
      concurrentWorkerCount: 4,
      chunkingStrategy: ChunkingStrategy.vad,
    ),
  }) async {
    final jsonString = await transcribeFromFile(filePath, options: options);
    if (jsonString == null) return null;

    try {
      return jsonString;
    } catch (e) {
      debugPrint('Error parsing transcription result: $e');
      rethrow;
    }
  }

  /// Creates a map of decoding options from a [DecodingOptions] object.
  ///
  /// This is a convenience method to convert a [DecodingOptions] object to a map
  /// that can be passed to [transcribeFromFile] or [transcribeFromFileAndParse].
  static Map<String, dynamic> createDecodingOptionsMap({
    String? task,
    String? language,
    double? temperature,
    int? sampleLen,
    int? bestOf,
    double? patience,
    double? lengthPenalty,
    bool? suppressBlank,
    bool? suppressTokens,
    bool? withoutTimestamps,
    double? maxInitialTimestamp,
    bool? wordTimestamps,
    String? prependPunctuations,
    String? appendPunctuations,
    double? logProbThreshold,
    double? noSpeechThreshold,
    double? compressionRatioThreshold,
    String? conditionOnPreviousText,
    String? prompt,
    String? chunkingStrategy,
  }) {
    return {
      if (task != null) 'task': task,
      if (language != null) 'language': language,
      if (temperature != null) 'temperature': temperature,
      if (sampleLen != null) 'sampleLen': sampleLen,
      if (bestOf != null) 'bestOf': bestOf,
      if (patience != null) 'patience': patience,
      if (lengthPenalty != null) 'lengthPenalty': lengthPenalty,
      if (suppressBlank != null) 'suppressBlank': suppressBlank,
      if (suppressTokens != null) 'suppressTokens': suppressTokens,
      if (withoutTimestamps != null) 'withoutTimestamps': withoutTimestamps,
      if (maxInitialTimestamp != null)
        'maxInitialTimestamp': maxInitialTimestamp,
      if (wordTimestamps != null) 'wordTimestamps': wordTimestamps,
      if (prependPunctuations != null)
        'prependPunctuations': prependPunctuations,
      if (appendPunctuations != null) 'appendPunctuations': appendPunctuations,
      if (logProbThreshold != null) 'logProbThreshold': logProbThreshold,
      if (noSpeechThreshold != null) 'noSpeechThreshold': noSpeechThreshold,
      if (compressionRatioThreshold != null)
        'compressionRatioThreshold': compressionRatioThreshold,
      if (conditionOnPreviousText != null)
        'conditionOnPreviousText': conditionOnPreviousText,
      if (prompt != null) 'prompt': prompt,
      if (chunkingStrategy != null) 'chunkingStrategy': chunkingStrategy,
    };
  }
}
