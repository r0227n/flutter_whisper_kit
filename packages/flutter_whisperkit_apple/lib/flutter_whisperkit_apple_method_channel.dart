import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whisperkit/src/models.dart';

import 'flutter_whisperkit_apple_platform_interface.dart';
import 'src/whisper_kit_message.g.dart';

/// An implementation of [FlutterWhisperkitApplePlatform] that uses method channels.
class MethodChannelFlutterWhisperkitApple
    extends FlutterWhisperkitApplePlatform {
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
  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _transcriptionStreamController.stream;

  /// The Pigeon-generated API for WhisperKit
  final _whisperKitMessage = WhisperKitMessage();

  /// Constructor that sets up the event channel listener
  MethodChannelFlutterWhisperkitApple() {
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
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  ) async {
    try {
      return _whisperKitMessage.loadModel(
        variant,
        modelRepo,
        redownload,
        storageLocation,
      );
    } on PlatformException catch (e) {
      debugPrint('Error loading model: ${e.message}');
      throw e;
    }
  }

  @override
  Future<String?> transcribeFromFile(
    String filePath,
    DecodingOptions options,
  ) async {
    try {
      return _whisperKitMessage.transcribeFromFile(filePath, options.toJson());
    } on PlatformException catch (e) {
      debugPrint('Error transcribing file: ${e.message}');
      throw e;
    }
  }

  @override
  Future<String?> startRecording(DecodingOptions options, bool loop) async {
    try {
      return _whisperKitMessage.startRecording(options.toJson(), loop);
    } on PlatformException catch (e) {
      debugPrint('Error starting recording: ${e.message}');
      throw e;
    }
  }

  @override
  Future<String?> stopRecording(bool loop) async {
    try {
      return _whisperKitMessage.stopRecording(loop);
    } on PlatformException catch (e) {
      debugPrint('Error stopping recording: ${e.message}');
      throw e;
    }
  }
}
