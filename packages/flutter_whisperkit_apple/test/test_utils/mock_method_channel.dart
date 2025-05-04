import 'dart:async';
import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';
import 'package:flutter_whisperkit/src/models.dart';

/// A mock implementation of [MethodChannelFlutterWhisperkit] for testing.
class MockMethodChannelFlutterWhisperkit
    extends MethodChannelFlutterWhisperkit {
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
  Stream<TranscriptionResult> get transcriptionStream =>
      _testStreamController.stream;

  /// Override the model progress stream to return our test stream
  @override
  Stream<Progress> get modelProgressStream =>
      _modelProgressStreamController.stream;

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
      throw InvalidArgumentsError(message: 'File path cannot be empty');
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
            {
              "word": "Hello",
              "tokens": [1],
              "start": 0.0,
              "end": 1.0,
              "probability": 0.9
            },
            {
              "word": "world",
              "tokens": [2],
              "start": 1.0,
              "end": 2.0,
              "probability": 0.8
            }
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
            {
              "word": "This",
              "tokens": [4],
              "start": 2.0,
              "end": 2.5,
              "probability": 0.9
            },
            {
              "word": "is",
              "tokens": [5],
              "start": 2.5,
              "end": 3.0,
              "probability": 0.8
            },
            {
              "word": "a",
              "tokens": [6],
              "start": 3.0,
              "end": 3.5,
              "probability": 0.7
            },
            {
              "word": "test",
              "tokens": [7],
              "start": 3.5,
              "end": 4.0,
              "probability": 0.9
            }
          ]
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
      _testStreamController.add(
        TranscriptionResult.fromJsonString('''
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
      '''),
      );
    });

    return 'Recording started';
  }

  /// Override stopRecording
  @override
  Future<String?> stopRecording({bool loop = true}) async {
    return 'Recording stopped';
  }
}
