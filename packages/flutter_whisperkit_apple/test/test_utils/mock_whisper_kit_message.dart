import 'package:flutter/services.dart';
import 'package:flutter_whisperkit/src/models.dart';
import 'package:flutter_whisperkit/src/whisper_kit_message.g.dart';

/// A mock implementation of [WhisperKitMessage] for testing.
class MockWhisperKitMessage implements WhisperKitMessage {
  @override
  final BinaryMessenger? pigeonVar_binaryMessenger = null;

  @override
  final String pigeonVar_messageChannelSuffix = '';

  /// Mock implementation of loadModel
  @override
  Future<String?> loadModel(
    String? variant,
    String? modelRepo,
    bool? redownload,
    int? storageLocation,
  ) async {
    return 'Model loaded successfully';
  }

  /// Mock implementation of transcribeFromFile
  @override
  Future<String?> transcribeFromFile(
    String filePath,
    Map<String, Object?> options,
  ) async {
    if (filePath.isEmpty) {
      throw WhisperKitError(
        code: WhisperKitErrorCode.invalidArguments,
        message: 'File path cannot be empty',
      );
    }

    // Mock JSON response for a successful transcription
    const mockJson = '''
    {
      "text": "Hello world. This is a test.",
      "segments": [
        {
          "id": 0,
          "seek": 0,
          "text": "Hello world.",
          "start": 0.0,
          "end": 2.0,
          "tokens": [1, 2, 3],
          "temperature": 1.0,
          "avgLogprob": -0.5,
          "compressionRatio": 1.2,
          "noSpeechProb": 0.1
        },
        {
          "id": 1,
          "seek": 0,
          "text": "This is a test.",
          "start": 2.0,
          "end": 4.0,
          "tokens": [4, 5, 6, 7],
          "temperature": 1.0,
          "avgLogprob": -0.4,
          "compressionRatio": 1.3,
          "noSpeechProb": 0.05
        }
      ],
      "language": "en",
      "timings": {
        "pipelineStart": 0.0,
        "firstTokenTime": 0.4,
        "inputAudioSeconds": 4.0,
        "audioLoading": 0.1,
        "audioProcessing": 0.2,
        "encoding": 0.3,
        "decodingLoop": 0.5,
        "fullPipeline": 1.0
      }
    }
    ''';

    return mockJson;
  }

  /// Mock implementation of startRecording
  @override
  Future<String?> startRecording(
    Map<String, Object?> options,
    bool loop,
  ) async {
    return 'Recording started';
  }

  /// Mock implementation of stopRecording
  @override
  Future<String?> stopRecording(bool loop) async {
    return 'Recording stopped';
  }
}
