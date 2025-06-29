import 'package:flutter/services.dart';

import '../models.dart';
import '../platform_specifics/flutter_whisper_kit_platform_interface.dart';
import '../whisper_kit_error.dart';

/// Service class for managing audio transcription operations.
///
/// This class handles all transcription-related operations including:
/// - File-based transcription
/// - Language detection
/// - Device information retrieval
class TranscriptionService {
  /// Helper function to handle platform calls with error handling
  Future<T> _handlePlatformCall<T>(Future<T> Function() platformCall) async {
    try {
      return await platformCall();
    } on PlatformException catch (e) {
      throw WhisperKitError.fromPlatformException(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Transcribes an audio file at the specified path.
  ///
  /// Processes an audio file and generates a text transcription using the
  /// loaded WhisperKit model. This method handles the entire transcription
  /// process, including audio loading, processing, and text generation.
  ///
  /// Parameters:
  /// - [filePath]: The path to the audio file to transcribe.
  ///   This should be a valid path to an audio file in a supported format.
  /// - [options]: Optional decoding options to customize the transcription process.
  ///   These options control various aspects of the transcription, such as
  ///   language, task type, temperature, and more.
  ///
  /// Returns a [Future] that completes with a [TranscriptionResult] containing
  /// the transcription text, segments, and timing information, or throws a
  /// [WhisperKitError] if transcription fails.
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
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.transcribeFromFile(
        filePath,
        options: options,
      ),
    );
  }

  /// Detects the language of an audio file.
  ///
  /// This method analyzes the audio content and determines the most likely
  /// language being spoken, along with confidence scores for various languages.
  ///
  /// Returns a [Future] that completes with a [LanguageDetectionResult] containing
  /// the detected language code and a map of language probabilities.
  ///
  /// Example:
  /// ```dart
  /// final result = await transcriptionService.detectLanguage(filePath);
  /// print('Detected language: ${result.language}');
  /// print('Language probabilities: ${result.probabilities}');
  /// ```
  Future<LanguageDetectionResult> detectLanguage(String audioPath) async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.detectLanguage(audioPath),
    );
  }

  /// Returns the name of the device.
  ///
  /// This method returns the name of the device running the application.
  /// It uses the `deviceName` method from the platform interface to get
  /// the device name.
  ///
  /// Returns the name of the device.
  ///
  /// Example:
  /// ```dart
  /// final deviceName = await transcriptionService.deviceName();
  /// print('Device name: $deviceName');
  /// ```
  Future<String> deviceName() async {
    return _handlePlatformCall(
      () => FlutterWhisperKitPlatform.instance.deviceName(),
    );
  }
}