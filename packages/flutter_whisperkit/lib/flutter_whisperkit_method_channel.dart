import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whisperkit/src/whisper_kit_message.g.dart';
import 'src/models.dart';

import 'flutter_whisperkit_platform_interface.dart';

/// An implementation of [FlutterWhisperKitPlatform] that uses method channels.
///
/// This class handles the communication between the Dart code and native platform
/// code using Flutter's MethodChannel and EventChannel mechanisms. It manages
/// the transcription and model loading processes by forwarding calls to the
/// native WhisperKit implementation.
class MethodChannelFlutterWhisperKit extends FlutterWhisperKitPlatform {
  /// The Pigeon-generated message interface for communicating with native code.
  final _whisperKitMessage = WhisperKitMessage();

  /// The event channel for streaming transcription results from native code.
  ///
  /// This channel receives real-time transcription updates during recording
  /// and forwards them to the [transcriptionStream].
  @visibleForTesting
  final EventChannel transcriptionStreamChannel = const EventChannel(
    'flutter_whisperkit/transcription_stream',
  );

  /// The event channel for streaming model loading progress from native code.
  ///
  /// This channel receives progress updates during model download and loading
  /// and forwards them to the [modelProgressStream].
  @visibleForTesting
  final EventChannel modelProgressStreamChannel = const EventChannel(
    'flutter_whisperkit/model_progress_stream',
  );

  /// Stream controller for transcription results.
  ///
  /// This controller manages the stream of transcription results that are
  /// received from the native code through the [transcriptionStreamChannel].
  final StreamController<TranscriptionResult> _transcriptionStreamController =
      StreamController<TranscriptionResult>.broadcast();

  /// Stream controller for model loading progress.
  ///
  /// This controller manages the stream of progress updates that are
  /// received from the native code through the [modelProgressStreamChannel].
  final StreamController<Progress> _modelProgressStreamController =
      StreamController<Progress>.broadcast();

  /// Constructor that sets up the event channel listeners.
  ///
  /// Initializes the event channels for transcription results and model loading
  /// progress, and sets up listeners to forward events to the appropriate
  /// stream controllers.
  MethodChannelFlutterWhisperKit() {
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
              // Parse the JSON string into a TranscriptionResult object
              _transcriptionStreamController.add(
                TranscriptionResult.fromJsonString(event),
              );
            } catch (e) {
              // Forward parsing errors to the stream
              _transcriptionStreamController.addError(
                Exception('Failed to parse transcription result: $e'),
              );
            }
          }
        }
      },
      onError: (dynamic error) {
        // Forward event channel errors to the stream
        _transcriptionStreamController.addError(error);
      },
    );

    // Listen to the model progress event channel and forward events to the stream controller
    modelProgressStreamChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        if (event is Map) {
          try {
            // Convert the map to a Progress object
            final progressMap = Map<String, dynamic>.from(event);
            final progress = Progress.fromJson(progressMap);
            _modelProgressStreamController.add(progress);
          } catch (e) {
            // Forward parsing errors to the stream
            _modelProgressStreamController.addError(
              Exception('Failed to parse progress data: $e'),
            );
          }
        }
      },
      onError: (dynamic error) {
        // Forward event channel errors to the stream
        _modelProgressStreamController.addError(error);
      },
    );
  }

  /// Loads a WhisperKit model.
  ///
  /// Delegates the model loading request to the native implementation through
  /// the Pigeon-generated message interface.
  ///
  /// Parameters:
  /// - [variant]: The model variant to load (e.g., 'tiny-en', 'base', 'small', 'medium', 'large-v2').
  /// - [modelRepo]: The repository to download the model from.
  /// - [redownload]: Whether to force redownload the model even if it exists locally.
  /// - [modelDownloadPath]: Custom path where the model should be downloaded.
  ///
  /// Returns a [Future] that completes with a success message when the model
  /// is loaded successfully, or an error message if loading fails.
  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    String? modelDownloadPath,
  }) async {
    return _whisperKitMessage.loadModel(
      variant,
      modelRepo,
      redownload,
      modelDownloadPath,
    );
  }

  /// Transcribes an audio file at the specified path.
  ///
  /// Delegates the transcription request to the native implementation through
  /// the Pigeon-generated message interface.
  ///
  /// Parameters:
  /// - [filePath]: The path to the audio file to transcribe.
  /// - [options]: Optional decoding options to customize the transcription process.
  ///
  /// Returns a [Future] that completes with a [TranscriptionResult] containing
  /// the transcription text, segments, and timing information.
  @override
  Future<TranscriptionResult?> transcribeFromFile(
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
    // Convert the options to a JSON map and send to native code
    final result = await _whisperKitMessage.transcribeFromFile(
      filePath,
      options.toJson(),
    );
    // Parse the JSON string result into a TranscriptionResult object
    return result != null ? TranscriptionResult.fromJsonString(result) : null;
  }

  /// Starts recording audio from the microphone for real-time transcription.
  ///
  /// Delegates the recording request to the native implementation through
  /// the Pigeon-generated message interface.
  ///
  /// Parameters:
  /// - [options]: Optional decoding options to customize the transcription process.
  /// - [loop]: If true, continuously transcribes audio in a loop until stopped.
  ///           If false, transcription happens when stopRecording is called.
  ///
  /// Returns a [Future] that completes with a success message if recording
  /// starts successfully.
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

  /// Stops recording audio and optionally triggers transcription.
  ///
  /// Delegates the stop recording request to the native implementation through
  /// the Pigeon-generated message interface.
  ///
  /// Parameters:
  /// - [loop]: Must match the loop parameter used when starting recording.
  ///
  /// Returns a [Future] that completes with a success message when recording
  /// is stopped. If [loop] is false, also triggers transcription of the recorded audio.
  @override
  Future<String?> stopRecording({bool loop = true}) async {
    return _whisperKitMessage.stopRecording(loop);
  }

  /// Stream of real-time transcription results.
  ///
  /// This stream emits [TranscriptionResult] objects containing the full
  /// transcription data as it becomes available. The stream will emit an
  /// empty result when recording stops.
  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      _transcriptionStreamController.stream;

  /// Stream of model loading progress updates.
  ///
  /// This stream emits [Progress] objects containing information about the
  /// ongoing task, including completed units, total units, and the progress fraction.
  @override
  Stream<Progress> get modelProgressStream =>
      _modelProgressStreamController.stream;
}
