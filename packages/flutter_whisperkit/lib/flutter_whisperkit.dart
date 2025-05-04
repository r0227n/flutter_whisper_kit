import 'dart:async';

import 'flutter_whisperkit_platform_interface.dart';
import 'src/models.dart';

// Export model loader for public use
export 'src/model_loader.dart';
export 'src/models/progress.dart';

/// The main entry point for the Flutter WhisperKit plugin.
class FlutterWhisperkit {
  /// Loads a WhisperKit model.
  ///
  /// [variant] - The model variant to load (e.g., 'tiny-en', 'base', 'small', 'medium', 'large-v2').
  /// [modelRepo] - The repository to download the model from (default: 'argmaxinc/whisperkit-coreml').
  /// [redownload] - Whether to force redownload the model even if it exists locally.
  /// [modelDownloadPath] - The path to download the model to.
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    String? modelDownloadPath,
  }) {
    return FlutterWhisperkitPlatform.instance.loadModel(
      variant,
      modelRepo: modelRepo,
      redownload: redownload,
      modelDownloadPath: modelDownloadPath,
    );
  }

  /// Transcribes an audio file at the specified path.
  ///
  /// [filePath] - The path to the audio file to transcribe.
  /// [options] - Optional decoding options to customize the transcription process.
  ///
  /// Returns a JSON string containing the transcription result with segments and timing information.
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
  }) {
    return FlutterWhisperkitPlatform.instance.transcribeFromFile(
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
    return FlutterWhisperkitPlatform.instance.startRecording(
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
  Future<String?> stopRecording({bool loop = true}) {
    return FlutterWhisperkitPlatform.instance.stopRecording(loop: loop);
  }

  /// Stream of real-time transcription results.
  ///
  /// This stream emits TranscriptionResult objects containing the full transcription data as it becomes available.
  /// The stream will emit an empty result when recording stops.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = flutterWhisperkit.transcriptionStream.listen((result) {
  ///   setState(() {
  ///     _transcriptionText = result.text;
  ///     _language = result.language;
  ///     _segments = result.segments;
  ///   });
  /// });
  ///
  /// // Don't forget to cancel the subscription when done
  /// subscription.cancel();
  /// ```
  Stream<TranscriptionResult> get transcriptionStream =>
      FlutterWhisperkitPlatform.instance.transcriptionStream;

  /// Stream of model loading progress updates.
  ///
  /// This stream emits Progress objects containing information about the ongoing task,
  /// including completed units, total units, and the progress fraction.
  Stream<Progress> get modelProgressStream =>
      FlutterWhisperkitPlatform.instance.modelProgressStream;
}
