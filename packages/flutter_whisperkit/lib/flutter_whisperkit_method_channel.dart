import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'src/models.dart';

import 'flutter_whisperkit_platform_interface.dart';

/// An implementation of [FlutterWhisperkitPlatform] that uses method channels.
class MethodChannelFlutterWhisperkit extends FlutterWhisperkitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_whisperkit');
  
  /// The event channel for streaming transcription results
  @visibleForTesting
  final EventChannel transcriptionStreamChannel = const EventChannel(
    'flutter_whisperkit/transcription_stream',
  );
  
  /// Stream controller for transcription results
  final StreamController<TranscriptionResult> _transcriptionStreamController =
      StreamController<TranscriptionResult>.broadcast();
  
  /// Stream of transcription results
  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _transcriptionStreamController.stream;
  
  /// Constructor that sets up the event channel listener
  MethodChannelFlutterWhisperkit() {
    // Listen to the event channel and forward events to the stream controller
    transcriptionStreamChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is String) {
          if (event.isEmpty) {
            // Empty string means recording stopped
            _transcriptionStreamController.add(const TranscriptionResult(
              text: '', segments: [], language: '', timings: TranscriptionTimings()));
          } else {
            try {
              _transcriptionStreamController.add(TranscriptionResult.fromJsonString(event));
            } catch (e) {
              _transcriptionStreamController.addError(Exception('Failed to parse transcription result: $e'));
            }
          }
        }
      },
      onError: (dynamic error) {
        _transcriptionStreamController.addError(error);
      },
    );
  }
  
  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  }) {
    throw UnimplementedError('Default implementation - should be overridden by platform implementations');
  }
  
  @override
  Future<String?> transcribeFromFile(String filePath, DecodingOptions options) {
    throw UnimplementedError('Default implementation - should be overridden by platform implementations');
  }
  
  @override
  Future<String?> startRecording(DecodingOptions options, bool loop) {
    throw UnimplementedError('Default implementation - should be overridden by platform implementations');
  }
  
  @override
  Future<String?> stopRecording(bool loop) {
    throw UnimplementedError('Default implementation - should be overridden by platform implementations');
  }
}
