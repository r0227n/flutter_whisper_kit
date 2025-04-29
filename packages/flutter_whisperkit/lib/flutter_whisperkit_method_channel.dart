import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whisperkit/src/whisper_kit_message.g.dart';
import 'src/models.dart';

import 'flutter_whisperkit_platform_interface.dart';

/// An implementation of [FlutterWhisperkitPlatform] that uses method channels.
class MethodChannelFlutterWhisperkit extends FlutterWhisperkitPlatform {
  final _whisperKitMessage = WhisperKitMessage();

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
            _transcriptionStreamController.add(
              const TranscriptionResult(
                text: '',
                segments: [],
                language: '',
                timings: TranscriptionTimings(),
              ),
            );
          } else {
            try {
              _transcriptionStreamController.add(
                TranscriptionResult.fromJsonString(event),
              );
            } catch (e) {
              _transcriptionStreamController.addError(
                Exception('Failed to parse transcription result: $e'),
              );
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
    ModelStorageLocation? storageLocation,
  }) async {
    return _whisperKitMessage.loadModel(
      variant,
      modelRepo,
      redownload,
      storageLocation?.index,
    );
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
    return _whisperKitMessage.transcribeFromFile(filePath, options.toJson());
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
    return _whisperKitMessage.startRecording(options.toJson(), loop);
  }

  @override
  Future<String?> stopRecording({bool loop = true}) async {
    return _whisperKitMessage.stopRecording(loop);
  }

  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _transcriptionStreamController.stream;
}
