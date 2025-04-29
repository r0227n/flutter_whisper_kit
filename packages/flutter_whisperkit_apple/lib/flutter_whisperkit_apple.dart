import 'dart:async';
import 'dart:convert';
import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'flutter_whisperkit_apple_method_channel.dart';

/// The main entry point for the Flutter WhisperKit Apple plugin.
class FlutterWhisperkitApple extends FlutterWhisperkitPlatform {
  /// Create a singleton instance
  static final FlutterWhisperkitApple _instance = FlutterWhisperkitApple._();

  /// Factory constructor to return the singleton instance
  factory FlutterWhisperkitApple() => _instance;

  /// Method channel implementation
  final MethodChannelFlutterWhisperkitApple _methodChannel = MethodChannelFlutterWhisperkitApple();

  /// Private constructor for singleton
  FlutterWhisperkitApple._() {
    // Register this implementation as the default instance
    FlutterWhisperkitPlatform.instance = this;
  }

  /// Loads a WhisperKit model.
  ///
  /// [variant] - The model variant to load (e.g., 'tiny-en', 'base', 'small', 'medium', 'large-v2').
  /// [modelRepo] - The repository to download the model from (default: 'argmaxinc/whisperkit-coreml').
  /// [redownload] - Whether to force redownload the model even if it exists locally.
  /// [storageLocation] - Where to store the model (0: package directory, 1: user folder).
  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  }) {
    return _methodChannel.loadModel(
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
  @override
  Future<String?> transcribeFromFile(
    String filePath,
    DecodingOptions options,
  ) async {
    return _methodChannel.transcribeFromFile(filePath, options);
  }

  /// Starts recording audio from the microphone for real-time transcription.
  ///
  /// [options] - Optional decoding options to customize the transcription process.
  /// [loop] - If true, continuously transcribes audio in a loop until stopped.
  ///          If false, transcription happens when stopRecording is called.
  ///
  /// Returns a success message if recording starts successfully.
  @override
  Future<String?> startRecording(DecodingOptions options, bool loop) {
    return _methodChannel.startRecording(options, loop);
  }

  /// Stops recording audio and optionally triggers transcription.
  ///
  /// [loop] - Must match the loop parameter used when starting recording.
  ///
  /// Returns a success message when recording is stopped.
  /// If [loop] is false, also triggers transcription of the recorded audio.
  @override
  Future<String?> stopRecording(bool loop) {
    return _methodChannel.stopRecording(loop);
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
