import 'dart:async';
import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';
import 'package:flutter_whisperkit/src/models.dart';
import 'mock_whisper_kit_message.dart';

/// A mock implementation of [MethodChannelFlutterWhisperkit] for testing.
class MockMethodChannelFlutterWhisperkit extends MethodChannelFlutterWhisperkit {
  /// Stream controller for test transcription results
  final StreamController<TranscriptionResult> _testStreamController =
      StreamController<TranscriptionResult>.broadcast();
      
  /// Stream controller for model progress updates
  final StreamController<Progress> _modelProgressStreamController =
      StreamController<Progress>.broadcast();

  /// Constructor
  MockMethodChannelFlutterWhisperkit() {
    // Add a test result to the stream after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _testStreamController.add(
        const TranscriptionResult(
          text: 'Test transcription',
          segments: [],
          language: 'en',
          timings: TranscriptionTimings(),
        ),
      );
    });
  }

  /// Override the transcription stream to return our test stream
  @override
  Stream<TranscriptionResult> get transcriptionStream => _testStreamController.stream;
  
  /// Override the model progress stream to return our test stream
  @override
  Stream<Progress> get modelProgressStream => _modelProgressStreamController.stream;
  
  /// Override loadModel to support progress tracking
  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    String? modelDownloadPath,
  }) async {
    // Simulate progress updates through the stream
    for (int i = 0; i <= 10; i++) {
      _modelProgressStreamController.add(
        Progress(
          completedUnitCount: i,
          totalUnitCount: 10,
          fractionCompleted: i / 10,
          isIndeterminate: false,
        ),
      );
      await Future.delayed(Duration(milliseconds: 10));
    }
    
    return 'Model loaded successfully';
  }
  
  /// Override transcribeFromFile to return a mock result
  @override
  Future<TranscriptionResult?> transcribeFromFile(
    String filePath, {
    DecodingOptions options = const DecodingOptions(),
  }) async {
    if (filePath.isEmpty) {
      throw InvalidArgumentsError(
        message: 'File path cannot be empty',
      );
    }
    
    // Return a mock transcription result
    return TranscriptionResult.fromJsonString('''
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
          "noSpeechProb": 0.1,
          "words": [
            {"word": "Hello", "start": 0.0, "end": 0.5},
            {"word": "world", "start": 0.5, "end": 1.0}
          ]
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
          "noSpeechProb": 0.05,
          "words": [
            {"word": "This", "start": 2.0, "end": 2.3},
            {"word": "is", "start": 2.3, "end": 2.5},
            {"word": "a", "start": 2.5, "end": 2.7},
            {"word": "test", "start": 2.7, "end": 3.0}
          ]
        }
      ],
      "language": "en",
      "timings": {
        "fullPipeline": 1.0
      }
    }
    ''');
  }
  
  /// Override startRecording to support custom options
  @override
  Future<String?> startRecording({
    DecodingOptions options = const DecodingOptions(
      verbose: true,
      task: DecodingTask.transcribe,
      language: 'ja',
    ),
    bool loop = true,
  }) async {
    // Emit a test result to the stream after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      _testStreamController.add(TranscriptionResult.fromJsonString('''
        {
          "text": "Test transcription",
          "segments": [
            {
              "id": 0,
              "seek": 0,
              "text": "Test transcription",
              "start": 0.0,
              "end": 2.0,
              "tokens": [1, 2, 3],
              "temperature": 1.0,
              "avgLogprob": -0.5,
              "compressionRatio": 1.2,
              "noSpeechProb": 0.1
            }
          ],
          "language": "en",
          "timings": {
            "fullPipeline": 1.0
          }
        }
      '''));
    });
    
    return 'Recording started';
  }
  
  /// Override stopRecording
  @override
  Future<String?> stopRecording({bool loop = true}) async {
    return 'Recording stopped';
  }
}
