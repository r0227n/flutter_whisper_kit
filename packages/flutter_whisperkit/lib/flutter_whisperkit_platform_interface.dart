import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'src/models.dart';

import 'flutter_whisperkit_method_channel.dart';

abstract class FlutterWhisperkitPlatform extends PlatformInterface {
  /// Constructs a FlutterWhisperkitPlatform.
  FlutterWhisperkitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWhisperkitPlatform _instance = MethodChannelFlutterWhisperkit();

  /// The default instance of [FlutterWhisperkitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWhisperkit].
  static FlutterWhisperkitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWhisperkitPlatform] when
  /// they register themselves.
  static set instance(FlutterWhisperkitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Loads a WhisperKit model.
  ///
  /// [variant] - The model variant to load (e.g., 'tiny-en', 'base', 'small', 'medium', 'large-v2').
  /// [modelRepo] - The repository to download the model from (default: 'argmaxinc/whisperkit-coreml').
  /// [redownload] - Whether to force redownload the model even if it exists locally.
  /// [modelPath] - Path to the CoreML model file (.mlmodelc or .mlpackage).
  ///               If null, the app's internal directory will be used as the default storage location.
  ///               If the specified path does not exist, an exception will be thrown.
  /// [prewarmMode] - Whether to prewarm the model (true) or load it immediately (false).
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    String? modelPath,
    bool? prewarmMode,
  }) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  /// Transcribes an audio file at the specified path.
  ///
  /// [filePath] - The path to the audio file to transcribe.
  /// [options] - Optional decoding options to customize the transcription process.
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
    throw UnimplementedError('transcribeFromFile() has not been implemented.');
  }

  /// Starts recording audio from the microphone for real-time transcription.
  ///
  /// [options] - Optional decoding options to customize the transcription process.
  /// [loop] - If true, continuously transcribes audio in a loop until stopped.
  ///          If false, transcription happens when stopRecording is called.
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
    throw UnimplementedError('startRecording() has not been implemented.');
  }

  /// Stops recording audio and optionally triggers transcription.
  ///
  /// [loop] - Must match the loop parameter used when starting recording.
  Future<String?> stopRecording({bool loop = true}) {
    throw UnimplementedError('stopRecording() has not been implemented.');
  }

  /// Stream of real-time transcription results.
  Stream<TranscriptionResult> get transcriptionStream {
    throw UnimplementedError('transcriptionStream has not been implemented.');
  }
}
