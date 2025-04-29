import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'src/whisper_kit_message.g.dart';

/// An implementation that uses method channels to communicate with the native platform.
class MethodChannelFlutterWhisperkitApple {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_whisperkit_apple');

  /// The event channel for streaming transcription results
  @visibleForTesting
  final EventChannel transcriptionStreamChannel = const EventChannel(
    'flutter_whisperkit_apple/transcription_stream',
  );

  /// Stream controller for transcription results
  final StreamController<TranscriptionResult> _transcriptionStreamController =
      StreamController<TranscriptionResult>.broadcast();

  /// Stream of transcription results
  Stream<TranscriptionResult> get transcriptionStream =>
      _transcriptionStreamController.stream;

  /// The Pigeon-generated API for WhisperKit
  final WhisperKitMessage _whisperKitMessage;

  /// Constructor that sets up the event channel listener
  MethodChannelFlutterWhisperkitApple({WhisperKitMessage? whisperKitMessage}) 
      : _whisperKitMessage = whisperKitMessage ?? WhisperKitMessage() {
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

  /// Handles platform exceptions and provides consistent error handling
  T _handlePlatformException<T>(String methodName, T Function() action) {
    try {
      return action();
    } on PlatformException catch (e) {
      debugPrint('Error in $methodName: ${e.message}');
      throw WhisperKitError.fromPlatformException(e);
    } catch (e) {
      debugPrint('Unexpected error in $methodName: $e');
      throw WhisperKitError(
        code: WhisperKitErrorCode.unknown,
        message: 'Unexpected error in $methodName: $e',
      );
    }
  }

  /// Loads a WhisperKit model.
  Future<String?> loadModel({
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  }) async {
    return _handlePlatformException('loadModel', () {
      return _whisperKitMessage.loadModel(
        variant,
        modelRepo,
        redownload,
        storageLocation,
      );
    });
  }

  /// Transcribes an audio file at the specified path.
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
    return _handlePlatformException('transcribeFromFile', () {
      return _whisperKitMessage.transcribeFromFile(filePath, options.toJson());
    });
  }

  /// Starts recording audio from the microphone for real-time transcription.
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
    return _handlePlatformException('startRecording', () {
      return _whisperKitMessage.startRecording(options.toJson(), loop);
    });
  }

  /// Stops recording audio and optionally triggers transcription.
  Future<String?> stopRecording({bool loop = true}) async {
    return _handlePlatformException('stopRecording', () {
      return _whisperKitMessage.stopRecording(loop);
    });
  }
}
