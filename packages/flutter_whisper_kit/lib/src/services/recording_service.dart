import 'package:flutter/services.dart';

import '../models.dart';
import '../platform_specifics/flutter_whisper_kit_platform_interface.dart';
import '../whisper_kit_error.dart';

/// Service class for managing audio recording and real-time transcription.
///
/// This class handles all recording-related operations including:
/// - Starting and stopping audio recording
/// - Managing transcription streams
/// - Handling real-time audio processing
class RecordingService {
  /// Helper function to handle platform calls with error handling
  Future<T> _handlePlatformCall<T>(Future<T> Function() platformCall) async {
    try {
      return await platformCall();
    } on PlatformException catch (e) {
      throw WhisperKitErrorType.fromPlatformException(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Starts recording audio from the microphone for real-time transcription.
  ///
  /// Begins capturing audio from the device's microphone and optionally
  /// starts real-time transcription. This method handles microphone permission
  /// requests, audio capture configuration, and transcription setup.
  ///
  /// Parameters:
  /// - [options]: Optional decoding options to customize the transcription process.
  ///   These options control various aspects of the transcription, such as
  ///   language, task type, temperature, and more.
  /// - [loop]: If true, continuously transcribes audio in a loop until stopped.
  ///   If false, transcription happens when stopRecording is called.
  ///
  /// Returns a [Future] that completes with a success message if recording
  /// starts successfully, or throws a [WhisperKitError] if starting recording fails.
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
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.startRecording(
        options: options,
        loop: loop,
      ),
    );
  }

  /// Stops recording audio and optionally triggers transcription.
  ///
  /// Stops the audio capture from the device's microphone and, depending on
  /// the [loop] parameter, may trigger transcription of the recorded audio.
  ///
  /// Parameters:
  /// - [loop]: Must match the loop parameter used when starting recording.
  ///   This ensures consistent behavior between starting and stopping recording.
  ///
  /// Returns a [Future] that completes with a success message when recording
  /// is stopped. If [loop] is false, also triggers transcription of the recorded audio.
  /// Throws a [WhisperKitError] if stopping recording fails.
  Future<String?> stopRecording({bool loop = true}) async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.stopRecording(loop: loop),
    );
  }

  /// Resets the transcription state.
  ///
  /// This method stops recording and resets the transcription timings.
  /// It should be called when starting a new transcription session.
  ///
  /// Returns a [Future] that completes with a success message if the state is cleared successfully,
  /// or throws a [WhisperKitError] if clearing fails.
  Future<String?> clearState() async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.clearState(),
    );
  }

  /// Sets the logging callback for WhisperKit.
  ///
  /// This method configures a callback function for tracking progress and debugging.
  /// The callback receives log messages with the specified level.
  ///
  /// Parameters:
  /// - [level]: The logging level (e.g., "debug", "info", "warning", "error").
  ///
  /// Throws a [WhisperKitError] if setting the logging callback fails.
  Future<void> loggingCallback({String? level}) async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.loggingCallback(level: level),
    );
  }

  /// Stream of real-time transcription results.
  ///
  /// This stream emits [TranscriptionResult] objects containing the full
  /// transcription data as it becomes available during real-time transcription.
  /// The stream will emit an empty result when recording stops.
  ///
  /// This getter provides access to the transcription stream, allowing clients
  /// to listen for and react to transcription updates in real-time.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = recordingService.transcriptionStream.listen((result) {
  ///   setState(() {
  ///     _transcriptionText = result.text;
  ///     _language = result.language;
  ///     _segments = result.segments;
  ///   });
  /// });
  ///
  /// // Don't forget to cancel the subscription when done
  /// subscription.cancel();
  /// ```
  Stream<TranscriptionResult> get transcriptionStream =>
      FlutterWhisperKitPlatform.instance.transcriptionStream;
}