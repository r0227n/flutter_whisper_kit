import 'dart:convert';
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

  /// Starts recording audio from the microphone for real-time transcription.
  ///
  /// [options] - Optional decoding options to customize the transcription process.
  /// [loop] - If true, continuously transcribes audio in a loop until stopped.
  ///          If false, you must manually call [transcribeCurrentBuffer] to get results.
  ///
  /// Returns a success message if recording starts successfully.
  Future<String?> startRecording({
    DecodingOptions options = const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'ja',
      temperature: 0.0,
      temperatureFallbackCount: 5,
      sampleLength: 224,
      usePrefillPrompt: true,
      usePrefillCache: true,
      skipSpecialTokens: true,
      withoutTimestamps: false,
      wordTimestamps: true,
      clipTimestamps: [0.0],
      concurrentWorkerCount: 4,
      chunkingStrategy: ChunkingStrategy.vad,
    ),
    bool loop = true,
  }) {
    return FlutterWhisperkitApplePlatform.instance.startRecording(
      options,
      loop,
    );
  }

  /// Stops recording audio and optionally triggers transcription.
  ///
  /// [loop] - Must match the loop parameter used when starting recording.
  ///
  /// Returns a success message when recording is stopped.
  /// If [loop] is false, also triggers transcription of the recorded audio.
  Future<String?> stopRecording({bool loop = true}) {
    return FlutterWhisperkitApplePlatform.instance.stopRecording(loop);
  }

  /// Transcribes the current audio buffer that has been recorded.
  ///
  /// [options] - Optional decoding options to customize the transcription process.
  ///
  /// Returns a [TranscriptionResult] containing the transcription with segments and timing information.
  Future<TranscriptionResult> transcribeCurrentBuffer({
    DecodingOptions options = const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'ja',
      temperature: 0.0,
      temperatureFallbackCount: 5,
      sampleLength: 224,
      usePrefillPrompt: true,
      usePrefillCache: true,
      skipSpecialTokens: true,
      withoutTimestamps: false,
      wordTimestamps: true,
      clipTimestamps: [0.0],
      concurrentWorkerCount: 4,
      chunkingStrategy: ChunkingStrategy.vad,
    ),
  }) async {
    final result = await FlutterWhisperkitApplePlatform.instance
        .transcribeCurrentBuffer(options);
    
    if (result == null) {
      throw Exception('Failed to execute transcription: result is null');
    }
    
    return TranscriptionResult.fromJson(
      jsonDecode(result) as Map<String, dynamic>,
    );
  }
}
