import 'dart:async';
import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';
import 'package:flutter_whisperkit/src/models.dart';

/// A mock implementation of [MethodChannelFlutterWhisperkit] for testing.
class MockMethodChannelFlutterWhisperkit extends MethodChannelFlutterWhisperkit {
  /// Stream controller for test transcription results
  final StreamController<TranscriptionResult> _testStreamController =
      StreamController<TranscriptionResult>.broadcast();
  
  /// Stream controller for test model progress updates
  final StreamController<Progress> _testProgressStreamController =
      StreamController<Progress>.broadcast();

  /// Constructor
  MockMethodChannelFlutterWhisperkit() : super() {
    // Add a test result to the transcription stream after a short delay
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
    
    // Add a test progress update to the progress stream after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _testProgressStreamController.add(
        const Progress(
          totalUnitCount: 100,
          completedUnitCount: 50,
          fractionCompleted: 0.5,
          isIndeterminate: false,
        ),
      );
    });
  }

  /// Override the transcription stream to return our test stream
  @override
  Stream<TranscriptionResult> get transcriptionStream => _testStreamController.stream;
  
  /// Override the model progress stream to return our test stream
  @override
  Stream<Progress> get modelProgressStream => _testProgressStreamController.stream;
}
