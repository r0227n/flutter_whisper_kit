import 'dart:async';
import 'package:flutter_whisperkit_apple/flutter_whisperkit_apple_method_channel.dart';
import 'package:flutter_whisperkit/src/models.dart';
import 'mock_whisper_kit_message.dart';

/// A mock implementation of [MethodChannelFlutterWhisperkitApple] for testing.
class MockMethodChannelFlutterWhisperkitApple extends MethodChannelFlutterWhisperkitApple {
  /// Stream controller for test transcription results
  final StreamController<TranscriptionResult> _testStreamController =
      StreamController<TranscriptionResult>.broadcast();

  /// Constructor
  MockMethodChannelFlutterWhisperkitApple() 
      : super(whisperKitMessage: MockWhisperKitMessage()) {
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
}
