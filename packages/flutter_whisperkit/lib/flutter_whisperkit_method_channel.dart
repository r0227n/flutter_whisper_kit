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
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'variant': variant,
        'modelRepo': modelRepo,
        'redownload': redownload,
        'storageLocation': storageLocation,
      };
      return await methodChannel.invokeMethod<String>('loadModel', arguments);
    } on PlatformException catch (e) {
      debugPrint('Error loading model: ${e.message}');
      rethrow;
    }
  }

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
    try {
      final Map<String, dynamic> arguments = {
        'filePath': filePath,
        'options': options.toJson(),
      };
      return await methodChannel.invokeMethod<String>('transcribeFromFile', arguments);
    } on PlatformException catch (e) {
      debugPrint('Error transcribing file: ${e.message}');
      rethrow;
    }
  }

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
  }) async {
    try {
      final Map<String, dynamic> arguments = {
        'options': options.toJson(),
        'loop': loop,
      };
      return await methodChannel.invokeMethod<String>('startRecording', arguments);
    } on PlatformException catch (e) {
      debugPrint('Error starting recording: ${e.message}');
      rethrow;
    }
  }

  @override
  Future<String?> stopRecording({bool loop = true}) async {
    try {
      return await methodChannel.invokeMethod<String>('stopRecording', {'loop': loop});
    } on PlatformException catch (e) {
      debugPrint('Error stopping recording: ${e.message}');
      rethrow;
    }
  }

  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _transcriptionStreamController.stream;
}
