import 'package:flutter_whisper_kit/flutter_whisper_kit.dart';
import 'package:flutter_whisper_kit/src/platform_specifics/flutter_whisper_kit_platform_interface.dart';

/// A mock implementation of [WhisperKitMessage] for testing.
class MockWhisperKitMessage extends FlutterWhisperKitPlatform {
  /// Mock implementation of loadModel
  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool redownload = false,
  }) async {
    return 'Model loaded successfully';
  }

  /// Mock implementation of transcribeFromFile
  @override
  Future<TranscriptionResult?> transcribeFromFile(
    String filePath, {
    DecodingOptions? options,
  }) async {
    if (filePath.isEmpty) {
      throw InvalidArgumentsError(
        message: 'File path cannot be empty',
        code: 5001,
      );
    }

    return TranscriptionResult(
      text: 'Hello world. This is a test.',
      language: 'en',
      segments: [
        TranscriptionSegment(
          id: 0,
          seek: 0,
          text: 'Hello world.',
          start: 0.0,
          end: 2.0,
          tokens: [1, 2, 3],
          temperature: 1.0,
          avgLogprob: -0.5,
          compressionRatio: 1.2,
          noSpeechProb: 0.1,
        ),
        TranscriptionSegment(
          id: 1,
          seek: 0,
          text: 'This is a test.',
          start: 2.0,
          end: 4.0,
          tokens: [4, 5, 6, 7],
          temperature: 1.0,
          avgLogprob: -0.4,
          compressionRatio: 1.3,
          noSpeechProb: 0.05,
        ),
      ],
      timings: TranscriptionTimings(
        pipelineStart: 0.0,
        firstTokenTime: 0.4,
        inputAudioSeconds: 4.0,
        audioLoading: 0.1,
        audioProcessing: 0.2,
        encoding: 0.3,
        decodingLoop: 0.5,
        fullPipeline: 1.0,
      ),
    );
  }

  /// Mock implementation of startRecording
  @override
  Future<String?> startRecording({
    bool loop = true,
    DecodingOptions? options,
  }) async {
    return 'Recording started';
  }

  /// Mock implementation of stopRecording
  @override
  Future<String?> stopRecording({bool loop = true}) async {
    return 'Recording stopped';
  }
}
