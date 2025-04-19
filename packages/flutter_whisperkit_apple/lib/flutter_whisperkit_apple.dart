import 'dart:async';

import 'package:flutter/services.dart';

import 'flutter_whisperkit_apple_platform_interface.dart';
import 'src/whisper_kit_api.dart' as pigeon;

/// Configuration class for WhisperKit initialization
class WhisperKitConfig {
  /// Path to the WhisperKit model
  final String? modelPath;

  /// Enable Voice Activity Detection
  final bool? enableVAD;

  /// Silence threshold for VAD fallback in milliseconds
  final int? vadFallbackSilenceThreshold;

  /// Temperature parameter for VAD
  final double? vadTemperature;

  /// Enable language identification
  final bool? enableLanguageIdentification;

  /// Creates a new WhisperKitConfig instance
  WhisperKitConfig({
    this.modelPath,
    this.enableVAD,
    this.vadFallbackSilenceThreshold,
    this.vadTemperature,
    this.enableLanguageIdentification,
  });

  /// Converts this config to the pigeon API config
  pigeon.WhisperKitConfig toPigeon() {
    return pigeon.WhisperKitConfig(
      modelPath: modelPath,
      enableVAD: enableVAD,
      vadFallbackSilenceThreshold: vadFallbackSilenceThreshold,
      vadTemperature: vadTemperature,
      enableLanguageIdentification: enableLanguageIdentification,
    );
  }
}

/// Segment of transcription with timing information
class TranscriptionSegment {
  /// The transcribed text for this segment
  final String text;

  /// Start time of the segment in seconds
  final double startTime;

  /// End time of the segment in seconds
  final double endTime;

  /// Creates a new TranscriptionSegment
  TranscriptionSegment({
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  /// Creates a TranscriptionSegment from a pigeon API segment
  factory TranscriptionSegment.fromPigeon(pigeon.TranscriptionSegment segment) {
    return TranscriptionSegment(
      text: segment.text,
      startTime: segment.startTime,
      endTime: segment.endTime,
    );
  }
}

/// Result of a transcription operation
class TranscriptionResult {
  /// The complete transcribed text
  final String text;

  /// List of segments with timing information
  final List<TranscriptionSegment> segments;

  /// Detected language code (if language identification is enabled)
  final String? language;

  /// Creates a new TranscriptionResult
  TranscriptionResult({
    required this.text,
    required this.segments,
    this.language,
  });

  /// Creates a TranscriptionResult from a pigeon API result
  factory TranscriptionResult.fromPigeon(pigeon.TranscriptionResult result) {
    return TranscriptionResult(
      text: result.text,
      segments:
          result.segments
              .map((segment) => TranscriptionSegment.fromPigeon(segment))
              .toList(),
      language: result.language,
    );
  }
}

/// Flutter plugin for WhisperKit on iOS and macOS
class FlutterWhisperkitApple {
  final _api = pigeon.WhisperKitApi();
  final _eventChannel = const EventChannel('flutter_whisperkit_apple/events');

  /// Stream of transcription progress updates
  late final Stream<double> _progressStream;

  /// Stream of interim transcription results
  late final Stream<TranscriptionResult> _interimResultStream;

  /// Singleton instance
  static final FlutterWhisperkitApple _instance = FlutterWhisperkitApple._();

  /// Factory constructor to return the singleton instance
  factory FlutterWhisperkitApple() => _instance;

  /// Private constructor
  FlutterWhisperkitApple._() {
    // Initialize event streams
    _progressStream = _eventChannel
        .receiveBroadcastStream('progress')
        .map((event) => event as double);

    _interimResultStream = _eventChannel
        .receiveBroadcastStream('interimResult')
        .map((event) {
          final map = Map<String, dynamic>.from(event);
          final result = pigeon.TranscriptionResult.decode(map);
          return TranscriptionResult.fromPigeon(result);
        });
  }

  /// Gets the platform version
  Future<String?> getPlatformVersion() {
    return FlutterWhisperkitApplePlatform.instance.getPlatformVersion();
  }

  /// Initializes WhisperKit with the provided configuration
  ///
  /// Returns true if initialization was successful
  Future<bool> initializeWhisperKit({WhisperKitConfig? config}) async {
    try {
      return await _api.initializeWhisperKit(
        config?.toPigeon() ?? pigeon.WhisperKitConfig(),
      );
    } on PlatformException catch (e) {
      throw 'Failed to initialize WhisperKit: ${e.message}';
    }
  }

  /// Transcribes an audio file at the specified path
  ///
  /// Returns a [TranscriptionResult] containing the transcribed text and segments
  Future<TranscriptionResult> transcribeAudioFile(String filePath) async {
    try {
      final result = await _api.transcribeAudioFile(filePath);
      return TranscriptionResult.fromPigeon(result);
    } on PlatformException catch (e) {
      throw 'Failed to transcribe audio file: ${e.message}';
    }
  }

  /// Starts streaming transcription
  ///
  /// Returns true if streaming was successfully started
  Future<bool> startStreamingTranscription() async {
    try {
      return await _api.startStreamingTranscription();
    } on PlatformException catch (e) {
      throw 'Failed to start streaming transcription: ${e.message}';
    }
  }

  /// Stops streaming transcription
  ///
  /// Returns a [TranscriptionResult] containing the final transcribed text and segments
  Future<TranscriptionResult> stopStreamingTranscription() async {
    try {
      final result = await _api.stopStreamingTranscription();
      return TranscriptionResult.fromPigeon(result);
    } on PlatformException catch (e) {
      throw 'Failed to stop streaming transcription: ${e.message}';
    }
  }

  /// Gets a list of available WhisperKit models
  Future<List<String>> getAvailableModels() async {
    try {
      return await _api.getAvailableModels();
    } on PlatformException catch (e) {
      throw 'Failed to get available models: ${e.message}';
    }
  }

  /// Stream of transcription progress updates
  Stream<double> get onTranscriptionProgress => _progressStream;

  /// Stream of interim transcription results
  Stream<TranscriptionResult> get onInterimTranscriptionResult =>
      _interimResultStream;
}
