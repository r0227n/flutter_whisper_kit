import 'dart:async';

import 'package:flutter_whisperkit/flutter_whisperkit_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'flutter_whisperkit_apple_method_channel.dart';

/// The iOS/macOS implementation of [FlutterWhisperkitPlatform].
abstract class FlutterWhisperkitApplePlatform extends FlutterWhisperkitPlatform {
  /// Constructs a FlutterWhisperkitApplePlatform.
  FlutterWhisperkitApplePlatform() : super();

  static final Object _token = Object();

  static FlutterWhisperkitApplePlatform _instance =
      MethodChannelFlutterWhisperkitApple();

  /// The default instance of [FlutterWhisperkitApplePlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWhisperkitApple].
  static FlutterWhisperkitApplePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWhisperkitApplePlatform] when
  /// they register themselves.
  static set instance(FlutterWhisperkitApplePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
  
  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  });
  
  @override
  Future<String?> transcribeFromFile(String filePath, DecodingOptions options);
  
  @override
  Future<String?> startRecording(DecodingOptions options, bool loop);
  
  @override
  Future<String?> stopRecording(bool loop);
  
  @override
  Stream<TranscriptionResult> get transcriptionStream;
}
