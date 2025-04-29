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
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  }) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  /// Transcribes an audio file at the specified path.
  Future<String?> transcribeFromFile(String filePath, DecodingOptions options) {
    throw UnimplementedError('transcribeFromFile() has not been implemented.');
  }

  /// Starts recording audio from the microphone for real-time transcription.
  Future<String?> startRecording(DecodingOptions options, bool loop) {
    throw UnimplementedError('startRecording() has not been implemented.');
  }

  /// Stops recording audio and optionally triggers transcription.
  Future<String?> stopRecording(bool loop) {
    throw UnimplementedError('stopRecording() has not been implemented.');
  }

  /// Stream of real-time transcription results.
  Stream<TranscriptionResult> get transcriptionStream {
    throw UnimplementedError('transcriptionStream has not been implemented.');
  }
}
