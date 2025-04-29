import 'dart:async';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'flutter_whisperkit_apple_method_channel.dart';

/// The main entry point for the Flutter WhisperKit Apple plugin.
class FlutterWhisperkitApple extends FlutterWhisperkitPlatform {
  /// Create a singleton instance
  static FlutterWhisperkitApple? _instance;

  /// Method channel implementation
  final MethodChannelFlutterWhisperkitApple _methodChannel;

  /// Factory constructor to return the singleton instance
  /// 
  /// For normal usage, this returns the singleton instance.
  /// For testing, you can provide a custom method channel implementation.
  factory FlutterWhisperkitApple({MethodChannelFlutterWhisperkitApple? methodChannel}) {
    if (methodChannel != null) {
      // For testing: create a new instance with the provided method channel
      return FlutterWhisperkitApple._(methodChannel: methodChannel);
    }
    
    // For normal usage: return or create the singleton instance
    _instance ??= FlutterWhisperkitApple._(
      methodChannel: MethodChannelFlutterWhisperkitApple()
    );
    return _instance!;
  }

  /// Constructor with optional method channel for testing
  FlutterWhisperkitApple._({required MethodChannelFlutterWhisperkitApple methodChannel}) 
      : _methodChannel = methodChannel {
    // Register this implementation as the default instance
    FlutterWhisperkitPlatform.instance = this;
  }

  /// Loads a WhisperKit model.
  ///
  /// [variant] - The model variant to load (e.g., 'tiny-en', 'base', 'small', 'medium', 'large-v2').
  /// [modelRepo] - The repository to download the model from (default: 'argmaxinc/whisperkit-coreml').
  /// [redownload] - Whether to force redownload the model even if it exists locally.
  /// [storageLocation] - Where to store the model (ModelStorageLocation.packageDirectory or ModelStorageLocation.userFolder).
  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    ModelStorageLocation? storageLocation,
  }) {
    return _methodChannel.loadModel(
      variant: variant,
      modelRepo: modelRepo,
      redownload: redownload,
      storageLocation: storageLocation,
    );
  }

  /// Transcribes an audio file at the specified path.
  ///
  /// [filePath] - The path to the audio file to transcribe.
  /// [options] - Optional decoding options to customize the transcription process.
  ///
  /// Returns a JSON string containing the transcription result with segments and timing information.
  @override
  Future<String?> transcribeFromFile(
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
    return _methodChannel.transcribeFromFile(
      filePath,
      options: options,
    );
  }

  /// Starts recording audio from the microphone for real-time transcription.
  ///
  /// [options] - Optional decoding options to customize the transcription process.
  /// [loop] - If true, continuously transcribes audio in a loop until stopped.
  ///          If false, transcription happens when stopRecording is called.
  ///
  /// Returns a success message if recording starts successfully.
  @override
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
    return _methodChannel.startRecording(
      options: options,
      loop: loop,
    );
  }

  /// Stops recording audio and optionally triggers transcription.
  ///
  /// [loop] - Must match the loop parameter used when starting recording.
  ///
  /// Returns a success message when recording is stopped.
  /// If [loop] is false, also triggers transcription of the recorded audio.
  @override
  Future<String?> stopRecording({bool loop = true}) {
    return _methodChannel.stopRecording(
      loop: loop,
    );
  }

  /// Stream of real-time transcription results.
  ///
  /// This stream emits TranscriptionResult objects containing the full transcription data as it becomes available.
  /// The stream will emit an empty result when recording stops.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = FlutterWhisperkit.instance.transcriptionStream.listen((result) {
  ///   setState(() {
  ///     _transcriptionText = result.text;
  ///     _segments = result.segments;
  ///     _language = result.language;
  ///   });
  /// });
  ///
  /// // Don't forget to cancel the subscription when done
  /// subscription.cancel();
  /// ```
  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _methodChannel.transcriptionStream;
}
