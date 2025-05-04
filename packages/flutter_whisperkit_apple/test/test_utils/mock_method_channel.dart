import 'dart:async';
import 'package:flutter_whisperkit/flutter_whisperkit_method_channel.dart';
import 'package:flutter_whisperkit/src/models.dart';

/// A mock implementation of [MethodChannelFlutterWhisperkit] for testing.
class MockMethodChannelFlutterWhisperkit
    extends MethodChannelFlutterWhisperkit {
  /// Mock response for loadModel
  String? mockLoadModelResponse;

  /// Mock response for transcribeFromFile
  TranscriptionResult? mockTranscribeResponse;

  /// Mock response for startRecording
  String? mockStartRecordingResponse;

  /// Mock response for stopRecording
  String? mockStopRecordingResponse;

  /// Mock stream for transcription results
  Stream<TranscriptionResult>? mockTranscriptionStream;

  /// Mock stream for model progress updates
  Stream<Progress>? mockProgressStream;

  @override
  Future<String?> loadModel(
    String? variant, {
    String? modelRepo,
    bool? redownload,
    String? modelDownloadPath,
  }) async {
    return mockLoadModelResponse;
  }

  @override
  Future<TranscriptionResult?> transcribeFromFile(
    String filePath, {
    DecodingOptions options = const DecodingOptions(),
  }) async {
    return mockTranscribeResponse;
  }

  @override
  Future<String?> startRecording({
    DecodingOptions options = const DecodingOptions(),
    bool loop = true,
  }) async {
    return mockStartRecordingResponse;
  }

  @override
  Future<String?> stopRecording({bool loop = true}) async {
    return mockStopRecordingResponse;
  }

  @override
  Stream<TranscriptionResult> get transcriptionStream =>
      mockTranscriptionStream ?? Stream.empty();

  @override
  Stream<Progress> get modelProgressStream =>
      mockProgressStream ?? Stream.empty();
}
